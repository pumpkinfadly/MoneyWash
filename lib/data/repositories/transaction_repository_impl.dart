import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:money_wash/core/exceptions/exceptions.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/data/datasources/local/local_transaction_datasource.dart';
import 'package:money_wash/data/datasources/remote/remote_transaction_datasource.dart';
import 'package:money_wash/data/models/transaction_model.dart';
import 'package:money_wash/domain/entities/transaction_entity.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final LocalTransactionDataSource localDataSource;
  final RemoteTransactionDataSource remoteDataSource;
  final Connectivity connectivity;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<bool> _isOnline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions() async {
    try {
      final transactions = await localDataSource.getAllTransactions();
      return Right(transactions.map((t) => t.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id) async {
    try {
      final transaction = await localDataSource.getTransactionById(id);
      if (transaction == null) {
        return Left(DatabaseFailure(message: 'Transaction not found'));
      }
      return Right(transaction.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>?> addTransaction(TransactionEntity transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      
      await localDataSource.insertTransaction(transactionModel);

      if (await _isOnline()) {
        try {
          final syncedTransaction = await remoteDataSource.createTransaction(transactionModel);
          await localDataSource.updateTransaction(syncedTransaction.copyWith(isSynced: true));
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
        } on NetworkException catch (e) {
          return Left(NetworkFailure(message: e.message));
        } on TimeoutException catch (e) {
          return Left(NetworkFailure(message: e.message));
        }
      }

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>?> updateTransaction(TransactionEntity transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      
      await localDataSource.updateTransaction(transactionModel);

      if (await _isOnline()) {
        try {
          await remoteDataSource.updateTransaction(transactionModel);
          await localDataSource.markAsSynced(transaction.id);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
        } on NetworkException catch (e) {
          return Left(NetworkFailure(message: e.message));
        } on TimeoutException catch (e) {
          return Left(NetworkFailure(message: e.message));
        }
      }

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>?> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);

      if (await _isOnline()) {
        try {
          await remoteDataSource.deleteTransaction(id);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
        } on NetworkException catch (e) {
          return Left(NetworkFailure(message: e.message));
        } on TimeoutException catch (e) {
          return Left(NetworkFailure(message: e.message));
        }
      }

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final transactions = await localDataSource.getTransactionsByDateRange(start, end);
      return Right(transactions.map((t) => t.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalIncome(DateTime start, DateTime end) async {
    try {
      final total = await localDataSource.getTotalByType('income', start, end);
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpense(DateTime start, DateTime end) async {
    try {
      final total = await localDataSource.getTotalByType('expense', start, end);
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncTransactions() async {
    try {
      if (!await _isOnline()) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final unsyncedTransactions = await localDataSource.getUnsyncedTransactions();

      if (unsyncedTransactions.isEmpty) {
        return const Right(null);
      }

      try {
        final syncedTransactions = await remoteDataSource.syncTransactions(unsyncedTransactions);

        for (final transaction in syncedTransactions) {
          await localDataSource.updateTransaction(transaction.copyWith(isSynced: true));
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return Left(NetworkFailure(message: e.message));
      }
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
