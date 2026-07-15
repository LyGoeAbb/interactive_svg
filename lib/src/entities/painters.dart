import 'package:flutter/material.dart';

class MultiPainter extends CustomPainter {
  MultiPainter({super.repaint, required this.painters});

  final List<CustomPainter> painters;

  @override
  void paint(Canvas canvas, Size size) {
    for (final painter in painters) {
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant MultiPainter oldDelegate) {
    if (oldDelegate.painters.length != painters.length) {
      return true;
    }
    for (int i = 0; i < painters.length; i++) {
      if (painters[i].shouldRepaint(oldDelegate.painters[i])) {
        return true;
      }
    }
    return false;
  }
}
