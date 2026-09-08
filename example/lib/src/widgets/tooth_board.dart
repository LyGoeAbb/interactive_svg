/*
 Created by sonnts996 on 10/10/25.
 Copyright (c) 2025 . All rights reserved.
*/

import 'package:flutter/material.dart';

import 'package:interactive_svg/interactive_svg.dart';
import 'teeth_ids.dart';
import 'teeth_interactive_selector.dart';
import 'visible_teeth.dart';

class ToothBoard extends StatefulWidget {
  const ToothBoard({
    super.key,
    this.alignment = Alignment.topLeft,
    this.fit = BoxFit.contain,
    this.showTouchableBounds = false,
  });

  final Alignment alignment;
  final BoxFit fit;
  final bool showTouchableBounds;

  @override
  State<ToothBoard> createState() => _ToothBoardState();
}

class _ToothBoardState extends State<ToothBoard> {
  final VisibleTeeth visibleTeeth = VisibleTeeth();

  final List<InteractiveSelector> interactiveComponents = const [
    TeethIds.txtDefault,
    TeethIds.txtLIC1,
    // Nướu
    TeethIds.LIC_1_L,
    TeethIds.LIC_1_R,
    TeethIds.LIL_4_L,
    TeethIds.LIL_4_R,
    TeethIds.LC_8_L,
    TeethIds.LC_8_R,
    TeethIds.LPM1_6_L,
    TeethIds.LPM1_6_R,
    TeethIds.LPM2_9_L,
    TeethIds.LPM2_9_R,
    TeethIds.UIC_2_L,
    TeethIds.UIC_2_R,
    TeethIds.UIL_3_L,
    TeethIds.UIL_3_R,
    TeethIds.UC_7_L,
    TeethIds.UC_7_R,
    TeethIds.UPM1_5_L,
    TeethIds.UPM1_5_R,
    TeethIds.UPM2_10_L,
    TeethIds.UPM2_10_R,
    // Răng
    TeethIds.LIC_1_L_ACTIVE,
    TeethIds.LIC_1_R_ACTIVE,
    TeethIds.LIL_4_L_ACTIVE,
    TeethIds.LIL_4_R_ACTIVE,
    TeethIds.LC_8_L_ACTIVE,
    TeethIds.LC_8_R_ACTIVE,
    TeethIds.LPM1_6_L_ACTIVE,
    TeethIds.LPM1_6_R_ACTIVE,
    TeethIds.LPM2_9_L_ACTIVE,
    TeethIds.LPM2_9_R_ACTIVE,
    TeethIds.UIC_2_L_ACTIVE,
    TeethIds.UIC_2_R_ACTIVE,
    TeethIds.UIL_3_L_ACTIVE,
    TeethIds.UIL_3_R_ACTIVE,
    TeethIds.UC_7_L_ACTIVE,
    TeethIds.UC_7_R_ACTIVE,
    TeethIds.UPM1_5_L_ACTIVE,
    TeethIds.UPM1_5_R_ACTIVE,
    TeethIds.UPM2_10_L_ACTIVE,
    TeethIds.UPM2_10_R_ACTIVE,
  ];

  BoundsList? boundsData;

  @override
  Widget build(BuildContext context) => InteractiveSvgView.fromAssets(
        svgAssets: 'assets/teeth.svg',
        selectors: interactiveComponents,
        alignment: widget.alignment,
        fit: widget.fit,
        shouldRebuildWhenBoundsCalculated: true,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            children: [
              const Icon(
                Icons.error,
                color: Colors.red,
              ),
              Text('$error'),
            ],
          ),
        ),
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        onTap: (details, selector) {
          if (selector is TeethInteractiveSelector) {
            onTap(selector);
          }
        },
        onBoundsCalculated: (boundsData) {
          setState(() {
            this.boundsData = boundsData;
          });
        },
        // interactiveBuilder: (context, builder, details) => Visibility(
        //   visible: isVisible(details.selector),
        //   child: () {
        //     if (details.selector is TeethInteractiveSelector) {
        //       final s = details.selector as TeethInteractiveSelector;
        //       if (s.group == TeethIds.teethActive && details.bounds != null) {
        //         return CustomPaint(
        //           foregroundPainter: LabelPainter(
        //             label: s.originId,
        //             bounds: details.bounds!.getVisibleBounds(),
        //           ),
        //           child: builder(details.svg),
        //         );
        //       }
        //     }
        //     return builder(details.svg);
        //   }(),
        // ),
        // markerBuilder: (context) {
        //   if (widget.showTouchableBounds && (boundsData?.isNotEmpty ?? false)) {
        //     return [
        //       Positioned.fill(
        //         child: CustomPaint(
        //           foregroundPainter: BoundsTestPainter(
        //             boundsData: boundsData!,
        //             boundsColor: Colors.red,
        //           ),
        //         ),
        //       ),
        //     ];
        //   }
        //   return [];
        // },
      );

  bool isVisible(InteractiveSelector selector) => switch (selector) {
        final TeethInteractiveSelector s => s.group == TeethIds.teethActive
            ? visibleTeeth.contains(s)
            : !visibleTeeth.contains(s),
        final InteractiveSelectorByID s => visibleTeeth.contains(s),
        _ => false,
      };

  void onTap(TeethInteractiveSelector selector) {
    debugPrint('Touch: $selector');
    if (visibleTeeth.contains(selector)) {
      setState(() {
        visibleTeeth.remove(selector);
        if (selector.truthId == TeethIds.LIL_4_R.truthId) {
          visibleTeeth.remove(TeethIds.txtLIC1);
        } else if (selector.truthId == TeethIds.UIL_3_R.truthId) {
          visibleTeeth.remove(TeethIds.txtDefault);
        }
      });
    } else {
      setState(() {
        visibleTeeth.put(selector);
        if (selector.truthId == TeethIds.LIL_4_R.truthId) {
          visibleTeeth.put(TeethIds.txtLIC1);
        } else if (selector.truthId == TeethIds.UIL_3_R.truthId) {
          visibleTeeth.put(TeethIds.txtDefault);
        }
      });
    }
  }
}

class LabelPainter extends CustomPainter {
  LabelPainter({super.repaint, required this.label, required this.bounds});

  final String label;
  final Rect bounds;

  @override
  void paint(Canvas canvas, Size size) {
    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );

    text.layout(maxWidth: size.width);

    final position = bounds.center - Offset(text.width / 2, text.height / 2);

    text.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant LabelPainter oldDelegate) =>
      oldDelegate.label != label || oldDelegate.bounds != bounds;
}
