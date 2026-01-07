import 'package:flutter_test/flutter_test.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/domain/entities/transaction_entity.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';
import 'package:money_wash/domain/usecases/add_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/delete_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/get_all_transactions_usecase.dart';
import 'package:money_wash/domain/usecases/get_summary_usecase.dart';
import 'package:money_wash/domain/usecases/sync_transactions_usecase.dart';
import 'package:money_wash/domain/usecases/update_transaction_usecase.dart';
import 'package:money_wash/presentation/providers/transaction_provider.dart';
import 'package:dartz/dartz.dart';

// Manual Mocks
// We need to implement the use cases but since they are concrete classes with a final field,
// we should extend them or implement them and provide a dummy repository.
// To make it simpler without mocking the repository for the use case constructor,
// we'll just mock the repository and use the real use cases, 
// OR simpler yet, just create a FakeRepository and inject it into real UseCases.

class FakeTransactionRepository implements TransactionRepository {
  @override
  Future<Either<Failure, void>?> addTransaction(TransactionEntity transaction) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>?> deleteTransaction(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, double>> getTotalExpense(DateTime start, DateTime end) async {
    return const Right(0.0);
  }

  @override
  Future<Either<Failure, double>> getTotalIncome(DateTime start, DateTime end) async {
     return const Right(0.0);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange(DateTime start, DateTime end) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> syncTransactions() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>?> updateTransaction(TransactionEntity transaction) async {
    return const Right(null);
  }
}

void main() {
  late TransactionProvider provider;
  late FakeTransactionRepository fakeRepository;
  late GetAllTransactionsUseCase getAll;
  late AddTransactionUseCase add;
  late DeleteTransactionUseCase delete;
  late UpdateTransactionUseCase update;
  late GetSummaryUseCase summary;
  late SyncTransactionsUseCase sync;

  setUp(() {
    fakeRepository = FakeTransactionRepository();
    
    getAll = GetAllTransactionsUseCase(fakeRepository);
    add = AddTransactionUseCase(fakeRepository);
    delete = DeleteTransactionUseCase(fakeRepository);
    update = UpdateTransactionUseCase(fakeRepository);
    summary = GetSummaryUseCase(fakeRepository);
    sync = SyncTransactionsUseCase(fakeRepository);

    provider = TransactionProvider(
      getAllTransactionsUseCase: getAll,
      addTransactionUseCase: add,
      deleteTransactionUseCase: delete,
      updateTransactionUseCase: update,
      getSummaryUseCase: summary,
      syncTransactionsUseCase: sync,
    );
  });

  test('Initial state should be correct', () {
    expect(provider.transactions, []);
    expect(provider.status, TransactionStatus.initial);
    expect(provider.errorMessage, null);
    expect(provider.summary, {'income': 0.0, 'expense': 0.0, 'balance': 0.0});
    expect(provider.isSyncing, false);
  });
  
  test('loadTransactions should update state to success', () async {
    await provider.loadTransactions();
    expect(provider.status, TransactionStatus.success);
    expect(provider.transactions, []);
  });
}
