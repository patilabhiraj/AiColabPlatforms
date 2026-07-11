import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/paginated_result.dart';
import '../entities/wallet_entity.dart';
import '../repositories/settings_repository.dart';

class GetWalletUseCase {
  final SettingsRepository repository;
  GetWalletUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call() {
    return repository.getWallet();
  }
}

class GetWalletTransactionsUseCase {
  final SettingsRepository repository;
  GetWalletTransactionsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<WalletTransactionEntity>>> call({
    required int page,
    required int pageSize,
    String? sort,
  }) {
    return repository.getWalletTransactions(
      page: page,
      pageSize: pageSize,
      sort: sort,
    );
  }
}
