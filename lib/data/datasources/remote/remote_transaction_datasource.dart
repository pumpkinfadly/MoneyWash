import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_wash/core/constants/api_constants.dart';
import 'package:money_wash/core/exceptions/exceptions.dart';
import 'package:money_wash/data/models/transaction_model.dart';

class RemoteTransactionDataSource {
  final http.Client client;

  RemoteTransactionDataSource({required this.client});

  Future<List<TransactionModel>> fetchAllTransactions() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactionsEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List;
        return jsonList
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch transactions',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw TimeoutException(message: 'Request timeout');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final response = await client
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactionsEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(transaction.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode == 201) {
        return TransactionModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: 'Failed to create transaction',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw TimeoutException(message: 'Request timeout');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      final response = await client
          .put(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactionsEndpoint}/${transaction.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(transaction.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode == 200) {
        return TransactionModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: 'Failed to update transaction',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw TimeoutException(message: 'Request timeout');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final response = await client
          .delete(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactionsEndpoint}/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to delete transaction',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw TimeoutException(message: 'Request timeout');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<List<TransactionModel>> syncTransactions(List<TransactionModel> transactions) async {
    try {
      final response = await client
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.syncEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'transactions': transactions.map((t) => t.toJson()).toList(),
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List;
        return jsonList
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to sync transactions',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw TimeoutException(message: 'Request timeout');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
