import 'package:dartz/dartz.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/domain/entities/transaction_entity.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<Either<Failure, void>?> call(TransactionEntity transaction) {
    return repository.updateTransaction(transaction);
  }
}
