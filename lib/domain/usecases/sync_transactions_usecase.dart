import 'package:dartz/dartz.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';

class SyncTransactionsUseCase {
  final TransactionRepository repository;

  SyncTransactionsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.syncTransactions();
  }
}
