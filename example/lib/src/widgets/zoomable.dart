import 'package:flutter/material.dart';

class ZoomController extends ChangeNotifier {
  double _scale = 1;
  Offset _position = Offset.zero;

  double get scale => _scale;

  Offset get position => _position;

  set scale(double value) {
    _scale = value.clamp(0.5, 5.0);
    notifyListeners();
  }

  void zoomTo(double scale, {Offset? focalPoint}) {
    final oldScale = this.scale;
    final focal = focalPoint ?? Offset.zero;

    // 🔥 FIXED: Tính relative position KHÔNG cần constraints
    final relativeX = (focal.dx + _position.dx) / oldScale;
    final relativeY = (focal.dy + _position.dy) / oldScale;

    this.scale = scale;
    _position = Offset(
      -relativeX * scale + focal.dx,
      -relativeY * scale + focal.dy,
    );
    notifyListeners();
  }

  void pan(Offset delta) {
    _position += delta;
    notifyListeners();
  }

  void reset() {
    scale = 1.0;
    _position = Offset.zero;
    notifyListeners();
  }
}

class Zoomable extends StatefulWidget {
  const Zoomable({
    super.key,
    required this.controller,
    required this.child,
    this.minScale = 0.5,
    this.maxScale = 5.0,
  });

  final ZoomController controller;
  final Widget child;
  final double minScale;
  final double maxScale;

  @override
  State<Zoomable> createState() => _ZoomableState();
}

class _ZoomableState extends State<Zoomable> {
  double _lastScale = 1;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          final scale =
              widget.controller.scale.clamp(widget.minScale, widget.maxScale);

          return LayoutBuilder(
            builder: (context, constraints) {
              // 🔥 FIXED: Smooth clamp với lerp transition
              final rawPosition = widget.controller.position;
              Offset finalPosition;

              if (scale <= 1.0) {
                // Scale ≤ 1: Drag tự do
                finalPosition = rawPosition;
              } else {
                // Scale > 1: Clamp boundary
                final maxX = (constraints.maxWidth * (scale - 1)) / 2;
                final maxY = (constraints.maxHeight * (scale - 1)) / 2;

                final clamped = Offset(
                  rawPosition.dx.clamp(-maxX, maxX),
                  rawPosition.dy.clamp(-maxY, maxY),
                );

                // 🔥 KEY FIX: Lerp khi cross boundary
                finalPosition = _lerpPosition(rawPosition, clamped, scale);
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleStart: (details) {
                  _lastScale = scale;
                },
                onScaleUpdate: (details) {
                  if (details.scale != 1.0) {
                    final newScale = (_lastScale * details.scale)
                        .clamp(widget.minScale, widget.maxScale);

                    widget.controller.zoomTo(
                      newScale,
                      focalPoint: details.focalPoint,
                    );
                  }

                  if (details.scale == 1.0 &&
                      details.focalPointDelta != Offset.zero) {
                    widget.controller.pan(details.focalPointDelta);
                  }
                },
                onScaleEnd: (_) {},
                child: Transform.scale(
                  scale: scale,
                  origin: Offset(
                    constraints.maxWidth / 2,
                    constraints.maxHeight / 2,
                  ),
                  child: Transform.translate(
                    offset: finalPosition,
                    child: widget.child,
                  ),
                ),
              );
            },
          );
        },
      );

  /// 🔥 MAGIC: Smooth transition khi cross scale = 1
  Offset _lerpPosition(Offset raw, Offset clamped, double scale) {
    if (scale <= 1.1) {
      // Transition zone: 1.0 - 1.1
      final t = (scale - 1.0) / 0.1; // 0.0 → 1.0
      return Offset.lerp(raw, clamped, t)!;
    }
    return clamped;
  }
}
