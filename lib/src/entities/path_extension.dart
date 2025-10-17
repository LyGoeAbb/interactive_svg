/*
 Created by sonnts996 on 14/10/25.
 Copyright (c) 2025 . All rights reserved.
*/
import 'dart:math';
import 'dart:ui';

/// Computes an axis-aligned bounding [Rect] that encloses the visible points of [path].
///
/// This function iterates over the [PathMetric]s returned by `path.computeMetrics()` and
/// samples points along each metric using tangents obtained via `getTangentForOffset`.
/// Sampling is performed at a fixed number of steps (default 100) across each metric's
/// length to approximate the visible extent of the path.
///
/// Important notes:
/// - The result is an approximation. Complex curves may have extrema between sampled points;
///   increase the sample count if you need higher accuracy.
/// - If the path has no metrics or contains no sampled points, the function returns [Rect.zero].
/// - Complexity: O(metrics * samples). For very large paths or a large sample count this may be
///   costly; tune the sample count accordingly.
///
/// Example:
/// ```dart
/// final bounds = getPathBounds(myPath);
/// final width = bounds.width;
/// ```
///
/// Parameters:
/// - [path]: the Path to measure.
///
/// Returns:
/// - An axis-aligned [Rect] that contains sampled points of the path, or [Rect.zero] if none.
Rect getPathBounds(Path path) {
  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = double.negativeInfinity;
  var maxY = double.negativeInfinity;

  final pathMetrics = path.computeMetrics();
  const samples = 100;

  for (final metric in pathMetrics) {
    final length = metric.length;
    if (length <= 0) continue; // skip degenerate metrics

    final step = length / samples;
    for (var i = 0; i <= samples; i++) {
      final t = (i == samples) ? length : (i * step);
      final tangent = metric.getTangentForOffset(t);
      if (tangent != null) {
        final position = tangent.position;
        minX = min(minX, position.dx);
        minY = min(minY, position.dy);
        maxX = max(maxX, position.dx);
        maxY = max(maxY, position.dy);
      }
    }
  }

  if (minX == double.infinity || minY == double.infinity) {
    return Rect.zero; // Return empty rect if no points were sampled.
  }

  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Extension methods for [Path] to compute visible bounds.
extension PathExtension on Path {
  /// Axis-aligned bounding rectangle of the visible portion of this [Path].
  ///
  /// This getter delegates to [getPathBounds] and therefore has the same approximation
  /// characteristics and performance considerations (sampling based).
  Rect get visibleBounds => getPathBounds(this);
}
