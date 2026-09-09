import 'package:cloud_firestore/cloud_firestore.dart';

/// Ҳолатҳои order (banди 11 спецификатсия, айнан бо ҳамин тартиб).
enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  shipped,
  delivering,
  completed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get value => name;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Дар интизорӣ';
      case OrderStatus.accepted:
        return 'Қабул шуд';
      case OrderStatus.preparing:
        return 'Омода мешавад';
      case OrderStatus.ready:
        return 'Омода аст';
      case OrderStatus.shipped:
        return 'Фиристода шуд';
      case OrderStatus.delivering:
        return 'Дар роҳ';
      case OrderStatus.completed:
        return 'Анҷом ёфт';
      case OrderStatus.cancelled:
        return 'Бекор карда шуд';
    }
  }

  /// Пайдарпаии мантиқии тартиб — барои "тугмаи навбатӣ" дар UI-и seller.
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.accepted;
      case OrderStatus.accepted:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.shipped;
      case OrderStatus.shipped:
        return OrderStatus.delivering;
      case OrderStatus.delivering:
        return OrderStatus.completed;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return null;
    }
  }
}

enum DeliveryType { delivery, pickup }

extension DeliveryTypeX on DeliveryType {
  String get value => name;
  static DeliveryType fromString(String value) =>
      DeliveryType.values.firstWhere((e) => e.value == value,
          orElse: () => DeliveryType.pickup);
  String get label =>
      this == DeliveryType.delivery ? 'Бо доставка' : 'Гирифтан аз ҷой';
}

/// Ҷузъи order (banди 27: `order_items`).
///
/// Қарори тарроҳӣ: дар PHASE 7 `order_items`-ро ҳамчун array дар дохили
/// худи документи `orders/{id}` нигоҳ медорем (embedded), НА ҳамчун
/// коллексияи алоҳида. Сабаб: як order одатан якчанд item дорад (на
/// садҳо), бинобар ин аз ҳудуди 1MB-и Firestore дур аст, ва embedded
/// хондани як order-ро ба 1 read (на N+1 read) кам мекунад — арзон дар
/// free-tier (banди 25). Агар дар оянда query-и мустақили "ин маҳсулот
/// дар кадом order-ҳо буд" лозим шавад, он вақт ба коллексияи алоҳида
/// мегузарем (banди 27 — тарҳи он ҳанӯз имконпазир аст).
class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String sellerId;
  final String? businessId;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.sellerId,
    this.businessId,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'price': price,
        'quantity': quantity,
        'sellerId': sellerId,
        'businessId': businessId,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        productImage: map['productImage'] as String? ?? '',
        price: (map['price'] as num).toDouble(),
        quantity: map['quantity'] as int,
        sellerId: map['sellerId'] as String,
        businessId: map['businessId'] as String?,
      );
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerCity;
  final String? customerAddress;
  final List<OrderItem> items;
  final DeliveryType deliveryType;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;

  /// Денормализатсияи қасдӣ: ID-ҳои ҳама seller-ҳое, ки дар ин order
  /// маҳсулот доранд — то query "orders барои ин seller" бе
  /// array-of-maps filtering кор кунад (Firestore array-contains).
  final List<String> sellerIds;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerCity,
    this.customerAddress,
    required this.items,
    required this.deliveryType,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.status = OrderStatus.pending,
    required this.sellerIds,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      customerCity: map['customerCity'] as String? ?? '',
      customerAddress: map['customerAddress'] as String?,
      items: ((map['items'] as List?) ?? const [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      deliveryType: DeliveryTypeX.fromString(map['deliveryType'] as String? ?? 'pickup'),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: OrderStatusX.fromString(map['status'] as String? ?? 'pending'),
      sellerIds:
          ((map['sellerIds'] as List?) ?? const []).map((e) => e as String).toList(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerCity': customerCity,
      'customerAddress': customerAddress,
      'items': items.map((e) => e.toMap()).toList(),
      'deliveryType': deliveryType.value,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.value,
      'sellerIds': sellerIds,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Пас аз `createOrder` (ки ID-и auto-generated-ро бармегардонад),
  /// барои сохтани нусхаи OrderModel бо ин ID (масалан барои экрани
  /// тасдиқ дарҳол пас аз checkout, бе интизори real-time listener).
  OrderModel copyWithId(String newId) {
    return OrderModel(
      id: newId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerCity: customerCity,
      customerAddress: customerAddress,
      items: items,
      deliveryType: deliveryType,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: status,
      sellerIds: sellerIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
