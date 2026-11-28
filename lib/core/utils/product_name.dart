/// Display normalization for product names ("HP BROPOOK 440 G7" → brand "HP",
/// model "ProBook 440 G7"). Presentation-only: data is also fixed at the source.
class ProductTitle {
  final String brand; // '' when unknown (e.g. Arabic-named accessories)
  final String model;
  const ProductTitle(this.brand, this.model);
  String get full => brand.isEmpty ? model : '$brand $model';
}

const _brands = <String, String>{
  'hp': 'HP', 'dell': 'Dell', 'lenovo': 'Lenovo', 'apple': 'Apple', 'acer': 'Acer', 'asus': 'ASUS',
  'samsung': 'Samsung', 'msi': 'MSI', 'microsoft': 'Microsoft', 'huawei': 'Huawei', 'xiaomi': 'Xiaomi',
  'logitech': 'Logitech', 'kingston': 'Kingston', 'sandisk': 'SanDisk', 'anker': 'Anker',
  'toshiba': 'Toshiba', 'sony': 'Sony', 'lg': 'LG', 'razer': 'Razer', 'jbl': 'JBL', 'oppo': 'OPPO',
  'tecno': 'TECNO', 'infinix': 'Infinix', 'realme': 'realme', 'nokia': 'Nokia',
};

const _lines = <String, String>{
  'probook': 'ProBook', 'elitebook': 'EliteBook', 'zbook': 'ZBook', 'thinkpad': 'ThinkPad',
  'ideapad': 'IdeaPad', 'latitude': 'Latitude', 'inspiron': 'Inspiron', 'precision': 'Precision',
  'xps': 'XPS', 'macbook': 'MacBook', 'zenbook': 'ZenBook', 'vivobook': 'VivoBook', 'aspire': 'Aspire',
  'swift': 'Swift', 'nitro': 'Nitro', 'legion': 'Legion', 'pavilion': 'Pavilion', 'envy': 'Envy',
  'spectre': 'Spectre', 'surface': 'Surface', 'tuf': 'TUF', 'rog': 'ROG', 'ssd': 'SSD', 'usb': 'USB',
  'usb-c': 'USB-C', 'hdmi': 'HDMI', 'gb': 'GB', 'tb': 'TB', 'ram': 'RAM', 'ddr4': 'DDR4', 'ddr5': 'DDR5',
  'iphone': 'iPhone', 'ipad': 'iPad', 'airpods': 'AirPods', 'galaxy': 'Galaxy', 'ultra': 'Ultra',
  'air': 'Air', 'pro': 'Pro', 'max': 'Max', 'mini': 'Mini', 'plus': 'Plus',
};

/// Known data typos (lowercase) → correct lowercase key in [_lines].
const _typos = <String, String>{
  'bropook': 'probook', 'bropok': 'probook', 'probok': 'probook', 'probbok': 'probook',
  'elitebok': 'elitebook', 'thinkpd': 'thinkpad', 'latitud': 'latitude', 'inspiron.': 'inspiron',
};

final _hasArabic = RegExp(r'[؀-ۿ]');
final _hasDigit = RegExp(r'\d');
final _intelCore = RegExp(r'^i[3579]$', caseSensitive: false);

String _fixToken(String t) {
  if (_hasArabic.hasMatch(t)) return t;
  final low = t.toLowerCase();
  final fixed = _typos[low] ?? low;
  final line = _lines[fixed];
  if (line != null) return line;
  if (_intelCore.hasMatch(t)) return low; // i5, i7
  if (_hasDigit.hasMatch(t)) {
    // 440, 15.6, G7, T480, M2 → keep digits, uppercase letters.
    return t.toUpperCase();
  }
  final isAllCaps = t.length > 1 && t == t.toUpperCase() && RegExp(r'^[A-Z\-]+$').hasMatch(t);
  if (isAllCaps) return t[0] + t.substring(1).toLowerCase();
  return t; // already mixed-case (e.g. MacBook) or Arabic
}

ProductTitle normalizeProductName(String raw) {
  final tokens = raw.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  if (tokens.isEmpty) return const ProductTitle('', '');
  var brand = '';
  var start = 0;
  final first = tokens.first.toLowerCase();
  if (_brands.containsKey(first)) {
    brand = _brands[first]!;
    start = 1;
  }
  final model = tokens.skip(start).map(_fixToken).join(' ');
  return ProductTitle(brand, model.isEmpty ? brand : model);
}

/// True when the title should be laid out LTR (Latin name inside RTL UI).
bool isLatinTitle(String s) => !_hasArabic.hasMatch(s);
