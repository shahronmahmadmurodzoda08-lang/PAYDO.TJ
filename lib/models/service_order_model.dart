import 'package:cloud_firestore/cloud_firestore.dart';

/// Ҳолатҳои фармоиши хизматрасонӣ — соддатар аз OrderStatus-и
/// marketplace (banди 14 нишон намедиҳад pipeline-и муфассал, бинобар
/// ин 4 ҳолати асосӣ кофист; ниг. эзоҳи тарроҳӣ дар docs/architecture.md).
enum ServiceOrderStatus { pending, accepted, completed, cancelled }

extension ServiceOrderStatusX on ServiceOrderStatus {
  String get value => name;
  static ServiceOrderStatus fromString(String value) =>
      ServiceOrderStatus.values.firstWhere((e) => e.value == value,
          orElse: () => ServiceOrderStatus.pending);

  String get label {
    switch (this) {
      case ServiceOrderStatus.pending:
        return 'Дар интизорӣ';
      case ServiceOrderStatus.accepted:
        return 'Қабул шуд';
      case ServiceOrderStatus.completed:
        return 'Анҷом ёфт';
      case ServiceOrderStatus.cancelled:
        return 'Бекор карда шуд';
    }
  }
}

/// Фармоиши хизматрасонӣ (banди 14: "Customer: ... order").
class ServiceOrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String providerId;
  final String providerName;
  final String serviceCategory;
  final String notes;
  final String city;
  final ServiceOrderStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceOrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.serviceCategory,
    this.notes = '',
    required this.city,
    this.status = ServiceOrderStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceOrderModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceOrderModel(
      id: id,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      serviceCategory: map['serviceCategory'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      city: map['city'] as String? ?? '',
      status: ServiceOrderStatusX.fromString(map['status'] as String? ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerId': providerId,
      'providerName': providerName,
      'serviceCategory': serviceCategory,
      'notes': notes,
      'city': city,
      'status': status.value,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
