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
  });

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
        pricesUpdatedAt: DateTime.tryParse((j['prices_updated_at'] ?? '').toString()),
      );
}
