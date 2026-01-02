import 'package:dartz/dartz.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<Either<Failure, void>?> call(String id) {
    return repository.deleteTransaction(id);
  }
}
