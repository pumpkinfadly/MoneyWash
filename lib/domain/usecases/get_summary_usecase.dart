import 'package:dartz/dartz.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';

class GetSummaryUseCase {
  final TransactionRepository repository;

  GetSummaryUseCase(this.repository);

  Future<Either<Failure, Map<String, double>>> call(DateTime start, DateTime end) async {
    final incomeResult = await repository.getTotalIncome(start, end);
    final expenseResult = await repository.getTotalExpense(start, end);

    return incomeResult.fold(
      (failure) => Left(failure),
      (income) => expenseResult.fold(
        (failure) => Left(failure),
        (expense) => Right({
          'income': income,
          'expense': expense,
          'balance': income - expense,
        }),
      ),
    );
  }
}
