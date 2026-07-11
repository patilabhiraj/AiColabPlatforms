import '../../domain/entities/wallet_entity.dart';
import 'json_parsing.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.tokensRemaining,
    required super.tokensUsed,
    super.currentPeriodStart,
    super.currentPeriodEnd,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: parseInt(json['id']),
      tokensRemaining: parseInt(json['tokensRemaining']),
      tokensUsed: parseInt(json['tokensUsed']),
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.tryParse(json['currentPeriodStart'].toString())
          : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.tryParse(json['currentPeriodEnd'].toString())
          : null,
    );
  }
}

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.createdAt,
    super.referenceId,
    super.meta,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: parseInt(json['id']),
      type: json['type']?.toString() ?? '',
      amount: parseInt(json['amount']),
      referenceId: json['referenceId']?.toString(),
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}
