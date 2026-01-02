# Money Wash - Personal Finance Tracker

## Overview
Money Wash is an offline-first personal finance tracker built with Flutter and Clean Architecture principles. The app allows users to track income and expenses, with automatic synchronization to a remote API when online.

## Architecture

### Clean Architecture Layers

#### 1. Domain Layer
Contains the core business logic and is independent of any external dependencies.

**Entities:**
- `TransactionEntity`: Represents a financial transaction with properties like id, title, amount, type, category, date, notes, and sync status.

**Repositories:**
- `TransactionRepository`: Abstract interface defining transaction operations (CRUD, sync, summaries).

**Use Cases:**
- `AddTransactionUseCase`: Handles adding new transactions
- `GetAllTransactionsUseCase`: Retrieves all transactions
- `DeleteTransactionUseCase`: Removes transactions
- `GetSummaryUseCase`: Calculates income, expense, and balance
- `SyncTransactionsUseCase`: Manages synchronization with remote API

#### 2. Data Layer
Handles data persistence and external API communication.

**Models:**
- `TransactionModel`: Data transfer object for transactions with JSON/Map serialization

**Data Sources:**
- `LocalTransactionDataSource`: SQLite database implementation for offline storage
- `RemoteTransactionDataSource`: HTTP client for remote API communication

**Repository Implementation:**
- `TransactionRepositoryImpl`: Concrete implementation combining local and remote data sources with connectivity checking

#### 3. Presentation Layer
Manages UI and user interactions.

**Providers:**
- `TransactionProvider`: State management using Provider pattern, handles loading states, errors, and data updates

**Screens:**
- `HomeScreen`: Main dashboard showing balance, summary, and transaction list
- `AddTransactionScreen`: Form for creating new transactions

## Key Features

### Offline-First Architecture
- All transactions are stored locally in SQLite
- App works fully offline
- Data persists across app restarts

### Automatic Synchronization
- Syncs to remote API when online
- Tracks sync status for each transaction
- Manual sync button available in the UI
- Graceful handling of network failures

### Error Handling
- Comprehensive error handling with custom exceptions and failures
- User-friendly error messages
- Retry mechanisms for failed operations

### Clean Code Principles
- Separation of concerns
- Dependency injection using Provider
- Single responsibility principle
- Testable architecture

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart        # API endpoints and configuration
│   ├── exceptions/
│   │   └── exceptions.dart           # Custom exception classes
│   └── failures/
│       └── failure.dart              # Failure types for error handling
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── local_transaction_datasource.dart  # SQLite operations
│   │   └── remote/
│   │       └── remote_transaction_datasource.dart # HTTP operations
│   ├── models/
│   │   └── transaction_model.dart    # Data transfer objects
│   └── repositories/
│       └── transaction_repository_impl.dart # Repository implementation
├── domain/
│   ├── entities/
│   │   └── transaction_entity.dart  # Business entities
│   ├── repositories/
│   │   └── transaction_repository.dart # Repository interfaces
│   └── usecases/
│       ├── add_transaction_usecase.dart
│       ├── delete_transaction_usecase.dart
│       ├── get_all_transactions_usecase.dart
│       ├── get_summary_usecase.dart
│       └── sync_transactions_usecase.dart
└── presentation/
    ├── providers/
    │   └── transaction_provider.dart # State management
    └── screens/
        ├── add_transaction_screen.dart
        └── home_screen.dart
```

## Dependencies

### Core
- `flutter`: UI framework
- `provider`: State management
- `dartz`: Functional programming utilities

### Data Persistence
- `sqflite`: SQLite database
- `path_provider`: File system access

### Networking
- `http`: HTTP client
- `connectivity_plus`: Network connectivity checking

### Utilities
- `equatable`: Value equality
- `uuid`: Unique ID generation
- `intl`: Date and number formatting

## API Configuration

The app expects a REST API with the following endpoints (configurable in `api_constants.dart`):

- `GET /transactions` - Fetch all transactions
- `POST /transactions` - Create a new transaction
- `PUT /transactions/:id` - Update a transaction
- `DELETE /transactions/:id` - Delete a transaction
- `POST /transactions/sync` - Sync multiple transactions

## Setup Instructions

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure API endpoint:**
   Edit `lib/core/constants/api_constants.dart` and set your API base URL:
   ```dart
   static const String baseUrl = 'https://your-api.com';
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

### Adding Transactions
1. Tap the + button on the home screen
2. Select transaction type (Income/Expense)
3. Enter title, amount, category, and date
4. Optionally add notes
5. Tap "Save Transaction"

### Viewing Transactions
- Home screen shows all transactions sorted by date
- Balance card displays total income, expense, and balance
- Pull down to refresh

### Synchronization
- Automatic sync when online (if API is configured)
- Manual sync via sync button in app bar
- Sync status indicator shows when syncing is in progress

## Error Handling

The app handles various error scenarios:

- **Network errors**: Gracefully handles offline mode
- **Database errors**: Shows user-friendly messages
- **Validation errors**: Form validation with clear error messages
- **Server errors**: Displays appropriate error messages

## Testing

The architecture supports comprehensive testing:

- **Unit tests**: Test use cases and business logic
- **Widget tests**: Test UI components
- **Integration tests**: Test data flow between layers

## Future Enhancements

- Transaction editing
- Search and filtering
- Categories management
- Reports and analytics
- Export data (CSV, PDF)
- Biometric authentication
- Cloud backup
- Multi-currency support
- Recurring transactions
- Budget tracking

## License

This project is private and proprietary.
