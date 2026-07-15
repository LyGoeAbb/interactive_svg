/*
 Created by sonnts996 on 15/10/25.
 Copyright (c) 2025 . All rights reserved.
*/

import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../interactive_svg.dart';

/// Builder used to decorate a parsed SVG region.
/// 
/// It returns an iterable of painter that will paint on top or below the svg
typedef PainterBuilder = Iterable<CustomPainter> Function(
  BuildContext context,
  SvgRegionsDetails details,
);

/// Builder that produces additional overlay widgets (markers) to be placed on top of the SVG.
///
/// The builder should return a list of widgets that will be inserted into the same stack as the SVG.
/// Use this to render labels, guides or diagnostic overlays.
/// - `context`: the build context.
// typedef MarkerBuilder = List<Widget> Function(
//   BuildContext context,
// );

/// Builder used to render an error state when SVG loading/parsing fails.
///
/// - `context`: the build context.
/// - `error`: the thrown error (may be null).
/// - `stackTrace`: optional stack trace.
typedef ErrorBuilder = Widget Function(
  BuildContext context,
  Object? error,
  StackTrace? stackTrace,
);

/// Mapping of interactive selectors to their computed hit-test bounds.
///
/// Uses LinkedHashMap to preserve insertion/render order. The keys are `InteractiveSelector`
/// instances and the values are `SvgBounds` (path/rect used for hit testing).
typedef BoundsList = LinkedHashMap<InteractiveSelector, SvgBounds>;

/// Mapping of optional selector -> SvgRegion fragments.
///
/// The `null` key represents the background/full SVG content. Non-null keys map to individual
/// region fragments (each associated with an InteractiveSelector).
typedef RegionList = LinkedHashMap<InteractiveSelector?, SvgRegion>;
