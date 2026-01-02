import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:money_wash/data/datasources/local/local_transaction_datasource.dart';
import 'package:money_wash/data/datasources/remote/remote_transaction_datasource.dart';
import 'package:money_wash/data/repositories/transaction_repository_impl.dart';
import 'package:money_wash/domain/repositories/transaction_repository.dart';
import 'package:money_wash/domain/usecases/add_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/delete_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/get_all_transactions_usecase.dart';
import 'package:money_wash/domain/usecases/get_summary_usecase.dart';
import 'package:money_wash/domain/usecases/update_transaction_usecase.dart';
import 'package:money_wash/domain/usecases/sync_transactions_usecase.dart';
import 'package:money_wash/presentation/providers/transaction_provider.dart';
import 'package:money_wash/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core dependencies
        Provider<Connectivity>(
          create: (_) => Connectivity(),
        ),
        Provider<http.Client>(
          create: (_) => http.Client(),
        ),
        
        // Data sources
        ProxyProvider<Connectivity, LocalTransactionDataSource>(
          update: (_, connectivity, __) => LocalTransactionDataSource(),
        ),
        ProxyProvider2<http.Client, Connectivity, RemoteTransactionDataSource>(
          update: (_, client, connectivity, __) => RemoteTransactionDataSource(
            client: client,
          ),
        ),
        
        // Repository
        ProxyProvider3<LocalTransactionDataSource, RemoteTransactionDataSource, Connectivity,
            TransactionRepository>(
          update: (_, localDataSource, remoteDataSource, connectivity, __) =>
              TransactionRepositoryImpl(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource,
            connectivity: connectivity,
          ),
        ),
        
        // Use cases
        ProxyProvider<TransactionRepository, GetAllTransactionsUseCase>(
          update: (_, repository, __) => GetAllTransactionsUseCase(repository),
        ),
        ProxyProvider<TransactionRepository, AddTransactionUseCase>(
          update: (_, repository, __) => AddTransactionUseCase(repository),
        ),
        ProxyProvider<TransactionRepository, DeleteTransactionUseCase>(
          update: (_, repository, __) => DeleteTransactionUseCase(repository),
        ),
        ProxyProvider<TransactionRepository, GetSummaryUseCase>(
          update: (_, repository, __) => GetSummaryUseCase(repository),
        ),
        ProxyProvider<TransactionRepository, UpdateTransactionUseCase>(
          update: (_, repository, __) => UpdateTransactionUseCase(repository),
        ),
        ProxyProvider<TransactionRepository, SyncTransactionsUseCase>(
          update: (_, repository, __) => SyncTransactionsUseCase(repository),
        ),
        
        // State management
        ChangeNotifierProvider<TransactionProvider>(
          create: (context) {
            final repository = context.read<TransactionRepository>();
            final getAllTransactionsUseCase = context.read<GetAllTransactionsUseCase>();
            final addTransactionUseCase = context.read<AddTransactionUseCase>();
            final deleteTransactionUseCase = context.read<DeleteTransactionUseCase>();
            final updateTransactionUseCase = context.read<UpdateTransactionUseCase>();
            final getSummaryUseCase = context.read<GetSummaryUseCase>();
            final syncTransactionsUseCase = context.read<SyncTransactionsUseCase>();
            
            return TransactionProvider(
              getAllTransactionsUseCase: getAllTransactionsUseCase,
              addTransactionUseCase: addTransactionUseCase,
              deleteTransactionUseCase: deleteTransactionUseCase,
              updateTransactionUseCase: updateTransactionUseCase,
              getSummaryUseCase: getSummaryUseCase,
              syncTransactionsUseCase: syncTransactionsUseCase,
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Money Wash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
