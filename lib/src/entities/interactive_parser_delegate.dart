/*
 Created by sonnts996 on 13/10/25.
 Copyright (c) 2025 . All rights reserved.
*/

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../../interactive_svg.dart';

part 'interactive_parse_context.dart';

part 'interactive_parser_delegate.g.dart';

/// Abstract delegate responsible for loading and parsing SVG assets for interactive usage.
///
/// Implementations must:
/// - load SVG content in [loadAssets] (this prepares internal parsing context, viewBox, etc.),
/// - return a mapping of selectors to rendered SVG fragments via [parseSvg],
/// - compute hit-test paths for touchable regions via [parseSvgBounds].
///
/// Important semantics:
/// - [loadAssets] should be awaited before calling [parseSvg] or [parseSvgBounds].
/// - [parseSvg] returns a [RegionList] where the `null` key holds the base/full SVG string.
/// - [parseSvgBounds] returns a [BoundsList] mapping selectors to [SvgBounds]; implementers should
///   transform paths into the coordinate space of the rendered widget using the provided `size`,
///   `fit` and `alignment`.
/// - [isChanged] should return true when the delegate's inputs (e.g., asset path or selectors)
///   differ from another instance, so callers know to reload resources.
abstract class InteractiveParserDelegate {
  /// Loads SVG assets and prepares the parsing context.
  ///
  /// This method MUST be called before any parsing operations. It may perform async I/O
  /// (reading asset bytes, parsing XML) and should populate whatever context is used by
  /// [parseSvg] / [parseSvgBounds].
  Future<void> loadAssets(BuildContext context);

  /// Parses the SVG and returns a map of region labels to [SvgRegion] objects.
  ///
  /// The key is the selector object, or `null` for the base/background SVG. Implementations
  /// should avoid performing layout-dependent calculations here; use [parseSvgBounds] for
  /// size-dependent bounds.
  RegionList parseSvg();

  /// Returns a map of touchable path bounds for interactive objects.
  ///
  /// The returned paths are expected to be in the coordinate space of the rendered widget
  /// given [size], with transformations applied according to [fit] and [alignment].
  BoundsList parseSvgBounds(
    Size size, {
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.topLeft,
  });

  /// Returns true if there is at least one touchable item in the SVG.
  bool get hasTouchableItem;

  /// Checks if this parser delegate is different from [other].
  ///
  /// Used to detect when a parser change requires reloading assets and recomputing bounds.
  bool isChanged(covariant InteractiveParserDelegate other);
}
