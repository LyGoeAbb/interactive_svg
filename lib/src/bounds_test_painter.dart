/*
 Created by sonnts996 on 14/10/25.
 Copyright (c) 2025 . All rights reserved.
*/

import 'package:flutter/cupertino.dart';

import '../interactive_svg.dart';

/// A [CustomPainter] used to visualize touchable areas for testing purposes.
///
/// This painter draws the provided SVG region bounds on the canvas,
/// allowing developers to see which areas are interactive or touchable.
/// Useful for debugging and verifying hit-test regions in interactive SVGs.
class BoundsTestPainter extends CustomPainter {
  /// Creates a [BoundsTestPainter].
  ///
  /// [boundsData] is a map of region labels to their corresponding [Path]s.
  /// [color] sets the fill or stroke color for the regions.
  BoundsTestPainter({
    super.repaint,
    required this.boundsData,
    this.color = const Color(0x3300FF00),
    Color? visibleBoundsColor,
    Color? boundsColor,
  })  : visibleBoundsColor = visibleBoundsColor ?? color,
        boundsColor = boundsColor ?? color;

  /// The map of region labels to their corresponding [Path]s.
  final BoundsList boundsData;

  /// The color used to draw the regions.
  final Color color;

  /// The color used to draw the stroke of `path.visibleBounds`.
  final Color visibleBoundsColor;

  /// The color used to draw the stroke of `path.getBounds`.
  final Color boundsColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = 1.0;

    final paintVisibleBounds = Paint()
      ..style = PaintingStyle.stroke
      ..color = visibleBoundsColor
      ..strokeWidth = 1.0;

    final paintBounds = Paint()
      ..style = PaintingStyle.stroke
      ..color = boundsColor
      ..strokeWidth = 1.0;

    for (final bounds in boundsData.values) {
      canvas.drawPath(bounds.path, paint);
      canvas.drawRect(bounds.getVisibleBounds(), paintVisibleBounds);
      canvas.drawRect(bounds.path.getBounds(), paintBounds);
    }
  }

  @override
  bool shouldRepaint(covariant BoundsTestPainter oldDelegate) =>
      oldDelegate.boundsData != boundsData || oldDelegate.color != color;
}
