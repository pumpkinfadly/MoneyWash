import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense,
}

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? notes;
  final bool isSynced;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [id, title, amount, type, category, date, notes, isSynced];
}
