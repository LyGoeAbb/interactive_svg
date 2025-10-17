/*
 Created by sonnts996 on 13/10/25.
 Copyright (c) 2025 . All rights reserved.
*/

// ignore: constant_identifier_names

import 'package:interactive_svg/interactive_svg.dart';

import 'teeth_interactive_selector.dart';

class TeethIds {
  // Enum-like InteractiveSelector values

  static const teethActive = 'Teeth_Active';
  static const teethDefault = 'Teeth_Default';

  static const txtDefault = InteractiveSelector.byID(id: 'Txt_Default');
  static const txtLIC1 = InteractiveSelector.byID(id: 'Txt_LIC_1');

  // Nướu
  static const LIC_1_L = TeethInteractiveSelector(
    id: 'LIC_1_L',
    group: teethDefault,
  );
  static const LIC_1_R = TeethInteractiveSelector(
    id: 'LIC_1_R',
    group: teethDefault,
  );
  static const LIL_4_L = TeethInteractiveSelector(
    id: 'LIL_4_L',
    group: teethDefault,
  );
  static const LIL_4_R = TeethInteractiveSelector(
    id: 'LIL_4_R',
    group: teethDefault,
  );
  static const LC_8_L = TeethInteractiveSelector(
    id: 'LC_8_L',
    group: teethDefault,
  );
  static const LC_8_R = TeethInteractiveSelector(
    id: 'LC_8_R',
    group: teethDefault,
  );
  static const LPM1_6_L = TeethInteractiveSelector(
    id: 'LPM1_6_L',
    group: teethDefault,
  );
  static const LPM1_6_R = TeethInteractiveSelector(
    id: 'LPM1_6_R',
    group: teethDefault,
  );
  static const LPM2_9_L = TeethInteractiveSelector(
    id: 'LPM2_9_L',
    group: teethDefault,
  );
  static const LPM2_9_R = TeethInteractiveSelector(
    id: 'LPM2_9_R',
    group: teethDefault,
  );
  static const UIC_2_L = TeethInteractiveSelector(
    id: 'UIC_2_L',
    group: teethDefault,
  );
  static const UIC_2_R = TeethInteractiveSelector(
    id: 'UIC_2_R',
    group: teethDefault,
  );
  static const UIL_3_L = TeethInteractiveSelector(
    id: 'UIL_3_L',
    group: teethDefault,
  );
  static const UIL_3_R = TeethInteractiveSelector(
    id: 'UIL_3_R',
    group: teethDefault,
  );
  static const UC_7_L = TeethInteractiveSelector(
    id: 'UC_7_L',
    group: teethDefault,
  );
  static const UC_7_R = TeethInteractiveSelector(
    id: 'UC_7_R',
    group: teethDefault,
  );
  static const UPM1_5_L = TeethInteractiveSelector(
    id: 'UPM1_5_L',
    group: teethDefault,
  );
  static const UPM1_5_R = TeethInteractiveSelector(
    id: 'UPM1_5_R',
    group: teethDefault,
  );
  static const UPM2_10_L = TeethInteractiveSelector(
    id: 'UPM2_10_L',
    group: teethDefault,
  );
  static const UPM2_10_R = TeethInteractiveSelector(
    id: 'UPM2_10_R',
    group: teethDefault,
  );

  // Răng (using $2 constructor)
  static const LIC_1_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LIC_1_L',
    group: teethActive,
  );
  static const LIC_1_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LIC_1_R',
    group: teethActive,
  );
  static const LIL_4_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LIL_4_L',
    group: teethActive,
  );
  static const LIL_4_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LIL_4_R',
    group: teethActive,
  );
  static const LC_8_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LC_8_L',
    group: teethActive,
  );
  static const LC_8_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LC_8_R',
    group: teethActive,
  );
  static const LPM1_6_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LPM1_6_L',
    group: teethActive,
  );
  static const LPM1_6_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LPM1_6_R',
    group: teethActive,
  );
  static const LPM2_9_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LPM2_9_L',
    group: teethActive,
  );
  static const LPM2_9_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'LPM2_9_R',
    group: teethActive,
  );
  static const UIC_2_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UIC_2_L',
    group: teethActive,
  );
  static const UIC_2_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UIC_2_R',
    group: teethActive,
  );
  static const UIL_3_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UIL_3_L',
    group: teethActive,
  );
  static const UIL_3_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UIL_3_R',
    group: teethActive,
  );
  static const UC_7_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UC_7_L',
    group: teethActive,
  );
  static const UC_7_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UC_7_R',
    group: teethActive,
  );
  static const UPM1_5_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UPM1_5_L',
    group: teethActive,
  );
  static const UPM1_5_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UPM1_5_R',
    group: teethActive,
  );
  static const UPM2_10_L_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UPM2_10_L',
    group: teethActive,
  );
  static const UPM2_10_R_ACTIVE = TeethInteractiveSelector.$2(
    id: 'UPM2_10_R',
    group: teethActive,
  );
}
