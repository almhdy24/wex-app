/// Spacing scale: 4 / 8 / 12 / 16 / 24 / 32 / 48 (+ legacy aliases used by older call sites).
abstract final class Sp {
  static const s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s24 = 24.0, s32 = 32.0, s48 = 48.0;
  // Legacy names mapped onto the new scale.
  static const x1 = 4.0, x2 = 4.0, x3 = 8.0, x4 = 8.0, x5 = 12.0, x6 = 12.0;
  static const x7 = 16.0, x8 = 16.0, x9 = 24.0, x10 = 32.0, x11 = 32.0, x12 = 48.0, x13 = 48.0;
  static const page = 16.0;
  static const section = 24.0;
}

/// Radii: 12 controls/thumbnails, 20 cards/banners, 28 sheet tops, 8 tags; pill only for count badges.
abstract final class Radii {
  static const tag = 8.0;
  static const control = 12.0;
  static const card = 20.0;
  static const sheetTop = 28.0;
  static const pill = 999.0;
  // Legacy aliases.
  static const sm = 8.0;
  static const panel = 20.0;
  static const card24 = 20.0;
  static const inner = 12.0;
  static const icon = 12.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
}
