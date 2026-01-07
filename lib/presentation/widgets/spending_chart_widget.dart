import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_wash/domain/entities/transaction_entity.dart';

class SpendingChartWidget extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const SpendingChartWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // 1. Filter expenses
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    
    if (expenses.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no expenses
    }

    // 2. Group by category and calculate totals
    final categoryTotals = <String, double>{};
    double totalExpense = 0;

    for (var t in expenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
      totalExpense += t.amount;
    }

    // 3. Sort by amount (descending)
    final sortedCategories = categoryTotals.keys.toList()
      ..sort((a, b) => categoryTotals[b]!.compareTo(categoryTotals[a]!));

    final currencyFormat = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((category) {
              final amount = categoryTotals[category]!;
              final percentage = amount / totalExpense;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(currencyFormat.format(amount)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCategoryColor(category),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Simple hashing for consistent colors
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }
}
