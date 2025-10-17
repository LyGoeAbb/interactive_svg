/*
 Created by sonnts996 on 16/10/25.
 Copyright (c) 2025 . All rights reserved.
*/
import 'dart:collection';

import 'package:interactive_svg/interactive_svg.dart';

import 'teeth_interactive_selector.dart';

extension InteractiveSelectorX on InteractiveSelector {
  String get truthId {
    if (this is TeethInteractiveSelector) {
      return (this as TeethInteractiveSelector).originId;
    }
    return id;
  }
}

class VisibleTeeth {
  final HashMap<String, InteractiveSelector> _visible = HashMap();

  bool contains(InteractiveSelector selector) =>
      _visible.containsKey(selector.truthId);

  void putOrRemove(InteractiveSelector selector) {
    if (contains(selector)) {
      _visible.removeWhere(
        (key, value) => key == selector.truthId,
      );
    } else {
      _visible[selector.truthId] = selector;
    }
  }

  void put(InteractiveSelector selector) {
    _visible[selector.truthId] = selector;
  }

  void remove(InteractiveSelector selector) {
    _visible.removeWhere(
      (key, value) => key == selector.truthId,
    );
  }
}
