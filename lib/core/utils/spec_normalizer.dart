import 'package:flutter/material.dart';

/// A normalized, ordered spec row with an icon.
class SpecRow {
  final String label;
  final String value;
  final IconData icon;
  const SpecRow(this.label, this.value, this.icon);
}

/// Canonical spec order + icons (what customers expect to see first).
const _order = <String, IconData>{
  'المعالج': Icons.memory_rounded,
  'الرام': Icons.developer_board_rounded,
  'التخزين': Icons.storage_rounded,
  'كرت الشاشة': Icons.videogame_asset_rounded,
  'الشاشة': Icons.desktop_windows_rounded,
  'البطارية': Icons.battery_charging_full_rounded,
};

/// Key aliases → canonical label (handles English/variant keys).
const _keyAlias = <String, String>{
  'cpu': 'المعالج', 'processor': 'المعالج', 'المعالِج': 'المعالج',
  'ram': 'الرام', 'memory': 'الرام', 'الذاكرة': 'الرام', 'الذاكرة العشوائية': 'الرام',
  'storage': 'التخزين', 'ssd': 'التخزين', 'hdd': 'التخزين', 'القرص': 'التخزين',
  'gpu': 'كرت الشاشة', 'graphics': 'كرت الشاشة', 'كرت الرسوميات': 'كرت الشاشة', 'كرت شاشة': 'كرت الشاشة',
  'display': 'الشاشة', 'screen': 'الشاشة',
  'battery': 'البطارية',
};

String _canonicalKey(String k) {
  final low = k.trim().toLowerCase();
  return _keyAlias[low] ?? _keyAlias[k.trim()] ?? k.trim();
}

/// Clean messy admin-entered values (Arabic transliterations → proper terms).
String normalizeSpecValue(String raw) {
  var v = raw.trim();
  const subs = {
    'قيقا': 'جيجابايت', 'جيقا': 'جيجابايت', 'غيغا': 'جيجابايت',
    'دسديارفور': 'DDR4', 'دي دي ار 4': 'DDR4', 'دي دي آر فور': 'DDR4',
    'دسديارفايف': 'DDR5', 'دي دي ار 5': 'DDR5',
    'اس اسدي': 'SSD', 'اس اس دي': 'SSD', 'إس إس دي': 'SSD',
    'اتش دي دي': 'HDD', 'انتل': 'Intel', 'اي 5': 'i5', 'اي 7': 'i7', 'اي 3': 'i3',
    'بوصه': 'بوصة',
  };
  subs.forEach((a, b) => v = v.replaceAll(a, b));
  return v;
}

bool _looksLikeScreen(String v) =>
    RegExp(r'\d{1,2}(\.\d)?').hasMatch(v) && (v.contains('بوصة') || v.contains('"') || RegExp(r'1[0-9](\.\d)?').hasMatch(v) && !v.toLowerCase().contains('gb'));
bool _looksLikeGpu(String v) {
  final low = v.toLowerCase();
  return low.contains('nvidia') || low.contains('rtx') || low.contains('gtx') ||
      low.contains('radeon') || low.contains('intel') || low.contains('uhd') ||
      low.contains('iris') || low.contains('amd') || v.contains('لا يوجد') || v.contains('مدمج');
}

/// Build the ordered, icon'd spec rows — and correct the common admin mistake
/// where "الشاشة" and "كرت الشاشة" values are swapped.
List<SpecRow> buildSpecRows(Map<String, String> specs) {
  final norm = <String, String>{};
  specs.forEach((k, v) => norm[_canonicalKey(k)] = normalizeSpecValue(v));

  // Fix swapped screen/GPU: screen value looks like a GPU and GPU value looks like a screen size.
  final screen = norm['الشاشة'];
  final gpu = norm['كرت الشاشة'];
  if (screen != null && gpu != null && _looksLikeGpu(screen) && _looksLikeScreen(gpu)) {
    norm['الشاشة'] = gpu;
    norm['كرت الشاشة'] = screen;
  }

  final rows = <SpecRow>[];
  for (final e in _order.entries) {
    final val = norm[e.key];
    if (val != null && val.isNotEmpty) rows.add(SpecRow(e.key, val, e.value));
  }
  // Any extra specs not in the canonical order, appended.
  for (final e in norm.entries) {
    if (!_order.containsKey(e.key) && e.value.isNotEmpty) {
      rows.add(SpecRow(e.key, e.value, Icons.check_circle_outline_rounded));
    }
  }
  return rows;
}

/// Short chips for a product card (CPU · RAM · Storage).
List<String> specChips(Map<String, String> specs) {
  final norm = <String, String>{};
  specs.forEach((k, v) => norm[_canonicalKey(k)] = normalizeSpecValue(v));
  String? shorten(String? v, {bool cpu = false}) {
    if (v == null || v.isEmpty) return null;
    if (cpu) {
      final m = RegExp(r'i[3579]').firstMatch(v) ?? RegExp(r'(Ryzen\s?\d)', caseSensitive: false).firstMatch(v);
      return m?.group(0) ?? (v.length > 10 ? v.substring(0, 10) : v);
    }
    final m = RegExp(r'\d+\s?(GB|TB|جيجابايت|تيرا)', caseSensitive: false).firstMatch(v);
    return m?.group(0)?.replaceAll('جيجابايت', 'GB') ?? v;
  }
  return [
    shorten(norm['المعالج'], cpu: true),
    shorten(norm['الرام']),
    shorten(norm['التخزين']),
  ].whereType<String>().toList();
}
