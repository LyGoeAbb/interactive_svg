/*
 Created by sonnts996 on 10/10/25.
 Copyright (c) 2025 . All rights reserved.
*/

import 'package:flutter/material.dart';

import 'widgets/tooth_board.dart';
import 'widgets/zoomable.dart';

class ToothCountView extends StatefulWidget {
  const ToothCountView({super.key});

  @override
  State<ToothCountView> createState() => _ToothCountViewState();
}

class _ToothCountViewState extends State<ToothCountView> {
  final ZoomController zoomController = ZoomController();
  bool showTouchableBounds = false;
  BoxFit boxFit = BoxFit.contain;
  Alignment alignment = Alignment.center;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final board = ClipRect(
              child: Zoomable(
                controller: zoomController,
                child: ToothBoard(
                  alignment: alignment,
                  fit: boxFit,
                  showTouchableBounds: showTouchableBounds,
                ),
              ),
            );
            final direction =
                constraints.maxWidth > 450 ? Axis.horizontal : Axis.vertical;
            return switch (direction) {
              Axis.horizontal => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: board),
                    _buildControlView(context, direction),
                  ],
                ),
              Axis.vertical => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: board),
                    _buildControlView(context, direction),
                  ],
                ),
            };
          },
        ),
      );

  Widget _buildControlView(BuildContext context, Axis direction) => Container(
        margin: switch (direction) {
          Axis.horizontal =>
            const EdgeInsets.only(top: 16, bottom: 16, right: 16),
          Axis.vertical =>
            const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        },
        constraints: direction == Axis.horizontal
            ? const BoxConstraints(
                minWidth: 220,
                maxWidth: 320,
              )
            : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (direction == Axis.horizontal)
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(-2, 0),
              )
            else
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildItem(
                direction,
                'BoxFit',
                DropdownButton(
                  value: boxFit,
                  items: BoxFit.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      boxFit = value ?? BoxFit.contain;
                    });
                  },
                ),
              ),
              _buildItem(
                direction,
                'Alignment',
                DropdownButton(
                  value: alignment,
                  items: [
                    (Alignment.topLeft, 'topLeft'),
                    (Alignment.topCenter, 'topCenter'),
                    (Alignment.topRight, 'topRight'),
                    (Alignment.bottomLeft, 'bottomLeft'),
                    (Alignment.bottomCenter, 'bottomCenter'),
                    (Alignment.bottomRight, 'bottomRight'),
                    (Alignment.centerLeft, 'centerLeft'),
                    (Alignment.center, 'center'),
                    (Alignment.centerRight, 'centerRight'),
                  ]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.$1,
                          child: Text(e.$2),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      alignment = value ?? Alignment.topLeft;
                    });
                  },
                ),
              ),
              _buildItem(
                direction,
                'Zoom',
                Transform.translate(
                  offset: const Offset(6, 0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      overlayShape: SliderComponentShape.noOverlay,
                      // Removes extra margin around the slider thumb/track
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      // You can further customize if needed
                      showValueIndicator: ShowValueIndicator.onlyForContinuous,
                    ),
                    child: Slider(
                      value: zoomController.scale,
                      onChanged: (value) {
                        setState(() {
                          zoomController.scale = value;
                        });
                      },
                      min: 0.5,
                      max: 5,
                    ),
                  ),
                ),
              ),
              _buildItem(
                direction,
                'Show touchable bounds',
                Switch(
                  value: showTouchableBounds,
                  onChanged: (value) {
                    setState(() {
                      showTouchableBounds = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildItem(Axis direction, String title, Widget item) => SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            item,
          ],
        ),
      );
}
