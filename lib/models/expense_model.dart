import 'package:cloud_firestore/cloud_firestore.dart';

/// Қайди хароҷот (banди 15: "Expenses"), ownerId — ниг. эзоҳи
/// тарроҳии DebtModel.
class ExpenseModel {
  final String id;
  final String ownerId;
  final String title;
  final double amount;
  final DateTime? date;
  final String? notes;
  final DateTime? createdAt;

  const ExpenseModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.amount,
    this.date,
    this.notes,
    this.createdAt,
  });

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: (map['date'] as Timestamp?)?.toDate(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'ownerId': ownerId,
      'title': title,
      'amount': amount,
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
      'notes': notes,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
