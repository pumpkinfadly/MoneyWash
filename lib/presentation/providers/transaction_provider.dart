import 'package:flutter/foundation.dart';
import 'package:money_wash/core/failures/failure.dart';
import 'package:money_wash/domain/entities/transaction_entity.dart';
import 'package:money_wash/domain/usecases/add_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/delete_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/get_all_transactions_usecase.dart';
import 'package:money_wash/domain/usecases/get_summary_usecase.dart';
import 'package:money_wash/domain/usecases/update_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/sync_transactions_usecase.dart';

enum TransactionStatus {
  initial,
  loading,
  success,
  error,
}

class TransactionProvider with ChangeNotifier {
  final GetAllTransactionsUseCase getAllTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final SyncTransactionsUseCase syncTransactionsUseCase;

  TransactionProvider({
    required this.getAllTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.getSummaryUseCase,
    required this.syncTransactionsUseCase,
  });

  List<TransactionEntity> _transactions = [];
  TransactionStatus _status = TransactionStatus.initial;
  String? _errorMessage;
  Map<String, double> _summary = {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
  bool _isSyncing = false;

  List<TransactionEntity> get transactions => _transactions;
  TransactionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, double> get summary => _summary;
  bool get isSyncing => _isSyncing;

  Future<void> loadTransactions() async {
    _status = TransactionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getAllTransactionsUseCase();

    result.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
      },
      (transactions) {
        _transactions = transactions;
        _status = TransactionStatus.success;
      },
    );

    notifyListeners();
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    _status = TransactionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await addTransactionUseCase(transaction);

    result?.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
      },
      (_) {
        _transactions.insert(0, transaction);
        _status = TransactionStatus.success;
      },
    );

    notifyListeners();
  }
  
  Future<void> reloadTransactions() async {
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    _status = TransactionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await updateTransactionUseCase(transaction);

    result?.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
      },
      (_) {
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _transactions[index] = transaction;
        }
        _status = TransactionStatus.success;
      },
    );

    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _status = TransactionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await deleteTransactionUseCase(id);

    result?.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
      },
      (_) {
        _transactions.removeWhere((t) => t.id == id);
        _status = TransactionStatus.success;
      },
    );

    notifyListeners();
  }

  Future<void> loadSummary(DateTime start, DateTime end) async {
    final result = await getSummaryUseCase(start, end);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (summary) {
        _summary = summary;
      },
    );

    notifyListeners();
  }

  Future<void> syncTransactions() async {
    _isSyncing = true;
    notifyListeners();

    final result = await syncTransactionsUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _errorMessage = null;
      },
    );

    _isSyncing = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
