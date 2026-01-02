import 'package:dartz/dartz.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/domain/entities/transaction_entity.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';

class GetAllTransactionsUseCase {
  final TransactionRepository repository;

  GetAllTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() {
    return repository.getAllTransactions();
  }
}
