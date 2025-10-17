/*
 Created by sonnts996 on 15/10/25.
 Copyright (c) 2025 . All rights reserved.
*/

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

import '../interactive_svg.dart';

/// Concrete [InteractiveParserDelegate] that loads an SVG asset and extracts
/// interactive regions and hit-test bounds according to provided [InteractiveSelector]s.
///
/// Usage:
/// 1. Call [loadAssets] with a BuildContext to load and parse the SVG asset (reads viewBox).
/// 2. Call [parseSvg] to obtain per-selector SVG fragments (the base SVG is stored under `null`).
/// 3. Call [parseSvgBounds] with a target [Size] (usually the rendered widget size) to obtain
///    path-based bounds for touchable selectors. Bounds are transformed according to the SVG
///    viewBox, provided `fit` and `alignment`.
class InteractiveParser extends InteractiveParserDelegate {
  /// Creates an [InteractiveParser] with the given [asset] and [selectors].
  InteractiveParser({required this.asset, this.selectors = const []});

  /// The SVG asset path to load.
  final String asset;

  /// The list of selectors defining interactive regions.
  final Iterable<InteractiveSelector> selectors;

  InteractiveParseContext? _currentContext;

  /// The current parsing context, including the XML document and viewBox.
  InteractiveParseContext? get currentContext => _currentContext;

  bool _lock = false;

  @override
  bool get hasTouchableItem =>
      selectors.any((e) => e.type == InteractiveType.touchable);

  /// Loads the SVG asset and parses its XML document.
  ///
  /// This method must be awaited before calling [parseSvg] or [parseSvgBounds].
  @override
  Future<void> loadAssets(BuildContext context) async {
    if (_lock) {
      return;
    }
    _lock = true;
    try {
      final svgString = await DefaultAssetBundle.of(context).loadString(asset);
      final document = XmlDocument.parse(svgString);
      final svg = document.findElements('svg').firstOrNull;
      _currentContext = InteractiveParseContext(root: svg, document: document);
      _parseViewBox(_currentContext!);
    } catch (e) {
      rethrow;
    } finally {
      _lock = false;
    }
  }

  void _parseViewBox(InteractiveParseContext context) {
    if (context.root == null) {
      return;
    }
    final viewBox = context.root!.getAttribute('viewBox');
    if (viewBox == null) {
      return;
    }
    // Parse viewBox to get dimensions
    final viewBoxParts =
        viewBox.split(' ').map((s) => double.tryParse(s) ?? 0).toList();
    if (viewBoxParts.length == 4) {
      final rect = Rect.fromLTWH(
        viewBoxParts[0],
        viewBoxParts[1],
        viewBoxParts[2],
        viewBoxParts[3],
      );
      _currentContext = context.copyWith(viewBox: rect);
    }
  }

  /// Parses the SVG and extracts regions based on the provided selectors.
  ///
  /// Returns a [RegionList] mapping each selector to an [SvgRegion]. The entry with key
  /// `null` contains the full/base SVG content (with the selected groups removed).
  /// Note: callers must call [loadAssets] prior to calling this method.
  @override
  RegionList parseSvg() {
    assert(!_lock, 'Please call loadAssets first and wait until it completes.');

    final context_ = _currentContext;
    assert(context_ != null, 'Please call loadAssets first.');
    assert(context_!.document != null, 'Please call loadAssets first.');
    assert(context_!.root != null, 'Please call loadAssets first.');

    final regions = RegionList();
    final context = context_!;

    /// Avoid editing on the original document
    final document = context.document!.copy();
    final root = context.root!.copy();

    for (final selector in selectors) {
      final group = selector(document);
      if (group == null) {
        continue;
      }
      group.remove();
      final region = _convertLayerToSvg(selector, group, root);
      regions[selector] = region;
    }
    regions[null] = SvgRegion(selector: null, svg: document.toString());
    return regions;
  }

  /// Converts a specific SVG layer to an [SvgRegion] for the given [selector].
  ///
  /// Returns an [SvgRegion] containing the SVG string for the selected layer.
  SvgRegion _convertLayerToSvg(
    InteractiveSelector selector,
    XmlNode layer,
    XmlElement root,
  ) {
    final element = XmlElement(
      root.name.copy(),
      root.attributes.map((e) => e.copy()).toList(),
      [layer.copy()],
      root.isSelfClosing,
    );
    return SvgRegion(selector: selector, svg: element.toString());
  }

  /// Parses the SVG and returns a map of selector -> [SvgBounds] (path) for touchable items.
  ///
  /// The returned paths are transformed to the target [size] according to [fit] and [alignment].
  /// Only selectors with `type == InteractiveType.touchable` are considered. If a selector's
  /// group is not found or no valid path can be constructed, that selector is skipped.
  @override
  BoundsList parseSvgBounds(
    Size size, {
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.topLeft,
  }) {
    assert(!_lock, 'Please call loadAssets first and wait until it completes.');

    final context_ = _currentContext;
    assert(context_ != null, 'Please call loadAssets first.');
    assert(context_!.document != null, 'Please call loadAssets first.');
    assert(context_!.viewBox != null, 'Please call loadAssets first.');

    final boundsRegions = BoundsList();
    final context = context_!;
    final document = context.document!;
    final viewBox = context.viewBox!;

    final touchableComponents =
        selectors.where((e) => e.type == InteractiveType.touchable);
    for (final selector in touchableComponents) {
      final group = selector(document);
      if (group == null) {
        continue;
      }
      final path = _parseBoundsFromSvg(
        group,
        size: size,
        viewBox: viewBox,
        alignment: alignment,
        fit: fit,
      );
      if (path != null) {
        boundsRegions[selector] = SvgBounds(path: path, selector: selector);
      }
    }
    return boundsRegions;
  }

  /// Parses a single SVG group/element and composes a union [Path] suitable for hit-testing.
  ///
  /// The method:
  /// - collects <path> elements (excluding those inside <mask>),
  /// - handles basic transforms (matrix(...)) found on the element or its parents,
  /// - applies mask clipping when a <mask> is referenced,
  /// - scales/translates the final path according to provided [viewBox], [size], [fit] and [alignment].
  ///
  /// Returns `null` if no usable path was found.
  Path? _parseBoundsFromSvg(
    XmlNode data, {
    Size? size,
    Rect? viewBox,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.topLeft,
  }) {
    final subpaths = <Path>[];
    Path? clipPath;
    Matrix4? transform;

    // Helper function to parse transform attribute to Matrix4
    Matrix4? parseTransform(String? transformStr) {
      if (transformStr == null || transformStr.isEmpty) return null;
      try {
        // Basic support for matrix(a b c d tx ty)
        if (transformStr.startsWith('matrix(')) {
          final values = transformStr
              .replaceFirst('matrix(', '')
              .replaceFirst(')', '')
              .split(RegExp(r'\s+|,'))
              .map((s) => double.tryParse(s) ?? 0.0)
              .toList();
          if (values.length >= 6) {
            return Matrix4(
              values[0],
              values[1],
              0,
              0,
              // a, b
              values[2],
              values[3],
              0,
              0,
              // c, d
              0,
              0,
              1,
              0,
              values[4],
              values[5],
              0,
              1, // tx, ty
            );
          }
        }
        // Add support for translate(), scale(), etc., if needed
      } catch (e) {
        debugPrint('Invalid transform format: $transformStr');
      }
      return null;
    }

    Path scaleBounds(Path path) {
      // Apply scaling if size, viewBox, fit, and alignment are provided
      if (size != null && viewBox != null) {
        var scaleX = size.width / viewBox.width;
        var scaleY = size.height / viewBox.height;
        var translateX = -viewBox.left; // Move Path to viewBox origin
        var translateY = -viewBox.top;

        // Adjust scale and translation based on BoxFit
        switch (fit) {
          case BoxFit.contain:
            final scale = scaleX < scaleY ? scaleX : scaleY;
            scaleX = scale;
            scaleY = scale;
            translateX += (size.width - viewBox.width * scale) *
                (alignment.x + 1) /
                2 /
                scaleX;
            translateY += (size.height - viewBox.height * scale) *
                (alignment.y + 1) /
                2 /
                scaleY;
          case BoxFit.cover:
            final scale = scaleX > scaleY ? scaleX : scaleY;
            scaleX = scale;
            scaleY = scale;
            translateX += (size.width - viewBox.width * scale) *
                (alignment.x + 1) /
                2 /
                scaleX;
            translateY += (size.height - viewBox.height * scale) *
                (alignment.y + 1) /
                2 /
                scaleY;
          case BoxFit.fitWidth:
            scaleY = scaleX;
            translateX += (size.width - viewBox.width * scaleX) *
                (alignment.x + 1) /
                2 /
                scaleX;
            translateY += (size.height - viewBox.height * scaleX) *
                (alignment.y + 1) /
                2 /
                scaleY;
          case BoxFit.fitHeight:
            scaleX = scaleY;
            translateX += (size.width - viewBox.width * scaleY) *
                (alignment.x + 1) /
                2 /
                scaleX;
            translateY += (size.height - viewBox.height * scaleY) *
                (alignment.y + 1) /
                2 /
                scaleY;
          case BoxFit.fill:
            translateX += (size.width - viewBox.width * scaleX) *
                (alignment.x + 1) /
                2 /
                scaleX;
            translateY += (size.height - viewBox.height * scaleY) *
                (alignment.y + 1) /
                2 /
                scaleY;
          case BoxFit.none:
            scaleX = 1.0;
            scaleY = 1.0;
            translateX += (size.width - viewBox.width) * (alignment.x + 1) / 2;
            translateY +=
                (size.height - viewBox.height) * (alignment.y + 1) / 2;
          case BoxFit.scaleDown:
            final scale = scaleX < scaleY ? scaleX : scaleY;
            scaleX = scale < 1.0 ? scale : 1.0;
            scaleY = scale < 1.0 ? scale : 1.0;
            translateX += (size.width - viewBox.width * scaleX) *
                (alignment.x + 1) /
                2 /
                scaleX;
            translateY += (size.height - viewBox.height * scaleY) *
                (alignment.y + 1) /
                2 /
                scaleY;
        }

        final scaleMatrix = Matrix4.identity()
          ..translate(translateX, translateY)
          ..scale(scaleX, scaleY, 1);
        return path.transform(scaleMatrix.storage);
      }
      return path;
    }

    // Check for mask in the element or its parent <g>
    XmlNode? current = data;
    String? maskId;
    while (current != null) {
      maskId = current
          .getAttribute('mask')
          ?.replaceFirst('url(#', '')
          .replaceFirst(')', '');
      if (maskId != null) break;
      current = current.parentElement;
    }

    // Parse mask if present to create clipPath
    if (maskId != null) {
      final mask = data.document?.findAllElements('mask').firstWhere(
            (e) => e.getAttribute('id') == maskId,
            orElse: () => throw Exception('Mask $maskId not found'),
          );
      if (mask != null) {
        for (final pathNode in mask.findAllElements('path')) {
          final d = pathNode.getAttribute('d') ?? '';
          if (d.isNotEmpty) {
            try {
              clipPath = parseSvgPathData(d);
              break; // Take first valid path for simplicity
            } catch (e) {
              debugPrint('Invalid mask path data: $e');
            }
          }
        }
      }
    }

    // Check for transform in the element or its parent <g>
    current = data;
    while (current != null) {
      final transformStr = current.getAttribute('transform');
      if (transformStr != null) {
        transform = parseTransform(transformStr);
        break;
      }
      current = current.parentElement;
    }

    // Parse paths, excluding those inside <mask>
    for (final pathNode in data.findAllElements('path')) {
      // Skip paths that are descendants of a <mask> element
      var parent = pathNode.parentElement;
      var isInMask = false;
      while (parent != null) {
        if (parent.name.local == 'mask') {
          isInMask = true;
          break;
        }
        parent = parent.parentElement;
      }
      if (isInMask) continue;

      final d = pathNode.getAttribute('d') ?? '';
      if (d.isNotEmpty) {
        try {
          final path = parseSvgPathData(d);
          subpaths.add(path);
        } catch (e) {
          debugPrint('Invalid path data: $e');
        }
      }
    }

    // Combine paths into a union for hit-testing
    if (subpaths.isNotEmpty) {
      var combinedUnion = Path();
      for (final p in subpaths) {
        combinedUnion.addPath(p, Offset.zero);
      }

      // Apply transform if present
      if (transform != null) {
        combinedUnion = combinedUnion.transform(transform.storage);
      }

      // Apply clipPath if present (intersect to get clipped bounds)
      if (clipPath != null) {
        combinedUnion =
            Path.combine(PathOperation.intersect, combinedUnion, clipPath);
      }

      return scaleBounds(combinedUnion);
    }
    return null;
  }

  /// Checks if this parser is different from [other].
  ///
  /// Returns true if the asset or selectors have changed.
  @override
  bool isChanged(covariant InteractiveParserDelegate other) {
    if (other is! InteractiveParser) return true;
    return other.asset != asset ||
        !const DeepCollectionEquality().equals(other.selectors, selectors);
  }
}
