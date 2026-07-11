import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final int id;
  final int tokensRemaining;
  final int tokensUsed;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;

  const WalletEntity({
    required this.id,
    required this.tokensRemaining,
    required this.tokensUsed,
    this.currentPeriodStart,
    this.currentPeriodEnd,
  });

  int get totalTokens => tokensRemaining + tokensUsed;

  double get usagePercent =>
      totalTokens > 0 ? (tokensUsed / totalTokens) * 100 : 0;

  @override
  List<Object?> get props =>
      [id, tokensRemaining, tokensUsed, currentPeriodStart, currentPeriodEnd];
}

class WalletTransactionEntity extends Equatable {
  final int id;
  final String type;
  final int amount;
  final String? referenceId;
  final Map<String, dynamic>? meta;
  final DateTime createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.referenceId,
    this.meta,
  });

  bool get isCredit => type == 'CREDIT';

  @override
  List<Object?> get props => [id, type, amount, referenceId, meta, createdAt];
}
