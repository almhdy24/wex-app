import '../../app/env.dart';

/// Order status (OrderStateMachine) + Arabic labels.
enum OrderStatus { pendingPayment, paymentReview, confirmed, readyForPickup, outForDelivery, completed, cancelled, expired, unknown }

OrderStatus orderStatusFrom(String? s) => switch (s) {
      'pending_payment' => OrderStatus.pendingPayment,
      'payment_review' => OrderStatus.paymentReview,
      'confirmed' => OrderStatus.confirmed,
      'ready_for_pickup' => OrderStatus.readyForPickup,
      'out_for_delivery' => OrderStatus.outForDelivery,
      'completed' => OrderStatus.completed,
      'cancelled' => OrderStatus.cancelled,
      'expired' => OrderStatus.expired,
      _ => OrderStatus.unknown,
    };

/// payment.state (PaymentStateService).
enum PaymentState { awaitingProof, underReview, rejected, approved, expired, notRequired, unknown }

PaymentState paymentStateFrom(String? s) => switch (s) {
      'awaiting_proof' => PaymentState.awaitingProof,
      'under_review' => PaymentState.underReview,
      'rejected' => PaymentState.rejected,
      'approved' => PaymentState.approved,
      'expired' => PaymentState.expired,
      'not_required' => PaymentState.notRequired,
      _ => PaymentState.unknown,
    };

class PaymentProof {
  final int id;
  final String status; // pending|approved|rejected|replaced
  final String? reviewNote;
  final String imageUrl; // relative API path (authed)
  final DateTime? uploadedAt;
  const PaymentProof({required this.id, required this.status, this.reviewNote, required this.imageUrl, this.uploadedAt});
  factory PaymentProof.fromJson(Map<String, dynamic> j) => PaymentProof(
        id: (j['id'] ?? 0) as int,
        status: (j['status'] ?? '').toString(),
        reviewNote: j['review_note']?.toString(),
        imageUrl: Env.assetUrl((j['image_url'] ?? '').toString()),
        uploadedAt: DateTime.tryParse((j['uploaded_at'] ?? j['created_at'] ?? '').toString()),
      );
}

class PaymentInfo {
  final PaymentState state;
  final bool canUpload;
  final PaymentProof? latestProof;
  const PaymentInfo({required this.state, required this.canUpload, this.latestProof});
  factory PaymentInfo.fromJson(Map<String, dynamic>? j) {
    j ??= {};
    final lp = (j['latest_proof'] is Map) ? Map<String, dynamic>.from(j['latest_proof']) : null;
    return PaymentInfo(
      state: paymentStateFrom(j['state']?.toString()),
      canUpload: j['can_upload'] == true,
      latestProof: lp == null ? null : PaymentProof.fromJson(lp),
    );
  }
}

class PaymentAccount {
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String? notes;
  const PaymentAccount({required this.bankName, required this.accountName, required this.accountNumber, this.notes});
  factory PaymentAccount.fromJson(Map<String, dynamic> j) => PaymentAccount(
        bankName: (j['bank_name'] ?? '').toString(),
        accountName: (j['account_name'] ?? '').toString(),
        accountNumber: (j['account_number'] ?? '').toString(),
        notes: j['notes']?.toString(),
      );
}

class OrderItem {
  final String name;
  final int quantity;
  final int lineTotalSdg;
  const OrderItem({required this.name, required this.quantity, required this.lineTotalSdg});
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        name: (j['product_name'] ?? j['name'] ?? '').toString(),
        quantity: ((j['quantity'] ?? 1) as num).round(),
        lineTotalSdg: ((j['line_total_sdg'] ?? 0) as num).round(),
      );
}

class TimelineEvent {
  final String statusText;
  final String? note;
  final DateTime? createdAt;
  const TimelineEvent({required this.statusText, this.note, this.createdAt});
  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
        statusText: (j['status_text'] ?? '').toString(),
        note: j['note']?.toString(),
        createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()),
      );
}

class OrderListItem {
  final String orderNumber;
  final OrderStatus status;
  final String statusLabel;
  final PaymentState paymentState;
  final int totalSdg;
  final DateTime? createdAt;
  const OrderListItem({required this.orderNumber, required this.status, required this.statusLabel, required this.paymentState, required this.totalSdg, this.createdAt});
  factory OrderListItem.fromJson(Map<String, dynamic> j) {
    final pay = (j['payment'] is Map) ? Map<String, dynamic>.from(j['payment']) : null;
    return OrderListItem(
      orderNumber: (j['order_number'] ?? '').toString(),
      status: orderStatusFrom(j['status']?.toString()),
      statusLabel: (j['status_label'] ?? '').toString(),
      paymentState: paymentStateFrom(pay?['state']?.toString()),
      totalSdg: ((j['total_sdg'] ?? j['total_amount_sdg'] ?? 0) as num).round(),
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()),
    );
  }
}

class OrderDetail {
  final String orderNumber;
  final OrderStatus status;
  final String statusLabel;
  final String deliveryType; // pickup|delivery
  final PaymentInfo payment;
  final int subtotalSdg;
  final int discountSdg;
  final int deliveryFeeSdg;
  final int totalSdg;
  final DateTime? lockExpiresAt;
  final int secondsRemaining;
  final List<PaymentAccount> paymentAccounts;
  final List<OrderItem> items;
  final List<TimelineEvent> timeline;

  const OrderDetail({
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.deliveryType,
    required this.payment,
    required this.subtotalSdg,
    required this.discountSdg,
    required this.deliveryFeeSdg,
    required this.totalSdg,
    this.lockExpiresAt,
    required this.secondsRemaining,
    this.paymentAccounts = const [],
    this.items = const [],
    this.timeline = const [],
  });

  bool get isPending => status == OrderStatus.pendingPayment;
  bool get isExpired => status == OrderStatus.expired;

  factory OrderDetail.fromJson(Map<String, dynamic> j) => OrderDetail(
        orderNumber: (j['order_number'] ?? '').toString(),
        status: orderStatusFrom(j['status']?.toString()),
        statusLabel: (j['status_label'] ?? '').toString(),
        deliveryType: (j['delivery_type'] ?? 'pickup').toString(),
        payment: PaymentInfo.fromJson((j['payment'] is Map) ? Map<String, dynamic>.from(j['payment']) : null),
        subtotalSdg: ((j['subtotal_sdg'] ?? 0) as num).round(),
        discountSdg: ((j['discount_sdg'] ?? 0) as num).round(),
        deliveryFeeSdg: ((j['delivery_fee_sdg'] ?? j['shipping_fee_sdg'] ?? 0) as num).round(),
        totalSdg: ((j['total_sdg'] ?? j['total_amount_sdg'] ?? 0) as num).round(),
        lockExpiresAt: DateTime.tryParse((j['lock_expires_at'] ?? j['expires_at'] ?? '').toString()),
        secondsRemaining: ((j['seconds_remaining'] ?? 0) as num).round(),
        paymentAccounts: (j['payment_accounts'] as List? ?? [])
            .map((e) => PaymentAccount.fromJson(Map<String, dynamic>.from(e))).toList(),
        items: (j['items'] as List? ?? [])
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e))).toList(),
        timeline: (j['timeline'] as List? ?? [])
            .map((e) => TimelineEvent.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
}
