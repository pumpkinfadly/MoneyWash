import 'package:dartz/dartz.dart';
import 'package:money_wash/domain/entities/transaction_entity.dart';
import 'package:money_wash/core/failures/failure.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions();
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);
  Future<Either<Failure, void>?> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>?> updateTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>?> deleteTransaction(String id);
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, double>> getTotalIncome(DateTime start, DateTime end);
  Future<Either<Failure, double>> getTotalExpense(DateTime start, DateTime end);
  Future<Either<Failure, void>> syncTransactions();
}
