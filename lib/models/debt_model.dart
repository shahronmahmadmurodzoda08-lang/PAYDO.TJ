import 'package:cloud_firestore/cloud_firestore.dart';

/// Қайди қарз (banди 15: "Debt book").
/// Қарори тарроҳӣ: `ownerId` (на businessId), то ҳар корбари
/// фурӯшанда — новобаста аз он ки Business Profile дорад ё не —
/// метавонад дафтари қарзи худро нигоҳ дорад (ҳамон мантиқи
/// `products.sellerId`, ниг. PHASE 6).
class DebtModel {
  final String id;
  final String ownerId;
  final String customerName;
  final String? phone;
  final double amount;
  final double paid;
  final DateTime? date;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DebtModel({
    required this.id,
    required this.ownerId,
    required this.customerName,
    this.phone,
    required this.amount,
    this.paid = 0,
    this.date,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  double get remaining => (amount - paid).clamp(0, amount);
  bool get isFullyPaid => remaining <= 0;

  factory DebtModel.fromMap(String id, Map<String, dynamic> map) {
    return DebtModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      phone: map['phone'] as String?,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      paid: (map['paid'] as num?)?.toDouble() ?? 0,
      date: (map['date'] as Timestamp?)?.toDate(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'ownerId': ownerId,
      'customerName': customerName,
      'phone': phone,
      'amount': amount,
      'paid': paid,
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
      'notes': notes,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
