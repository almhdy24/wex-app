/// Spacing scale (px) — tokens.css --space-1..16.
abstract final class Sp {
  static const x1 = 4.0, x2 = 6.0, x3 = 8.0, x4 = 10.0, x5 = 12.0, x6 = 14.0;
  static const x7 = 16.0,
      x8 = 20.0,
      x9 = 24.0,
      x10 = 32.0,
      x11 = 40.0,
      x12 = 48.0,
      x13 = 64.0;
  static const page = 16.0;
  static const section = 24.0;
}

abstract final class Radii {
  static const sm = 6.0;
  static const control = 10.0;
  static const card = 12.0;
  static const panel = 14.0;
  static const pill = 999.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}
