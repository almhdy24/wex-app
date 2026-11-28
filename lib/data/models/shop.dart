import '../../core/format/store_status.dart';
class Shop {
  final String name;
  final String address;
  final String phone;
  final String whatsapp;
  final String workingHours;
  final String shopMapLink;
  final int lockHours;
  final int appDiscountPercent;
  final bool ordersEnabled;
  final String ordersDisabledMessage;
  final bool tickerEnabled;
  final DateTime? pricesUpdatedAt;
  /// Opening windows per ISO weekday (1=Mon..7=Sun); null when the owner has not set `store_hours`.
  final Map<int, DayHours?>? storeHours;

  const Shop({
    required this.name,
    required this.address,
    required this.phone,
    required this.whatsapp,
    required this.workingHours,
    required this.shopMapLink,
    required this.lockHours,
    required this.appDiscountPercent,
    required this.ordersEnabled,
    required this.ordersDisabledMessage,
    required this.tickerEnabled,
    this.pricesUpdatedAt,
    this.storeHours,
  });

  static Map<int, DayHours?>? _hours(dynamic raw) {
    if (raw is! Map) return null;
    int? mins(dynamic v) {
      final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch((v ?? '').toString());
      return m == null ? null : int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
    }

    final out = <int, DayHours?>{};
    raw.forEach((k, v) {
      final d = int.tryParse(k.toString());
      if (d == null || d < 1 || d > 7) return;
      if (v is Map) {
        final o = mins(v['open']);
        final c = mins(v['close']);
        out[d] = (o == null || c == null) ? null : DayHours(o, c);
      } else {
        out[d] = null;
      }
    });
    return out.isEmpty ? null : out;
  }

  factory Shop.fromJson(Map<String, dynamic> j) => Shop(
        name: (j['name'] ?? 'ويكس تكنولوجي').toString(),
        address: (j['address'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        whatsapp: (j['whatsapp'] ?? '').toString(),
        workingHours: (j['working_hours'] ?? '').toString(),
        shopMapLink: (j['shop_map_link'] ?? '').toString(),
        lockHours: ((j['lock_hours'] ?? 4) as num).round(),
        appDiscountPercent: ((j['app_discount_percent'] ?? 3) as num).round(),
        ordersEnabled: j['orders_enabled'] != false,
        ordersDisabledMessage: (j['orders_disabled_message'] ?? '').toString(),
        tickerEnabled: j['ticker_enabled'] == true,
        pricesUpdatedAt:
            DateTime.tryParse((j['prices_updated_at'] ?? '').toString()),
        storeHours: _hours(j['store_hours']),
      );
}
