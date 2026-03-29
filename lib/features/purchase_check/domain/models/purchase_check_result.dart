import 'purchase_risk_status.dart';

class PurchaseCheckResult {
  const PurchaseCheckResult({
    required this.status,
    required this.purchaseAmount,
    required this.categoryName,
    required this.categoryRemainingBefore,
    required this.categoryRemainingAfter,
    required this.overallRemainingBefore,
    required this.overallRemainingAfter,
    required this.explanation,
  });

  final PurchaseRiskStatus status;
  final double purchaseAmount;
  final String categoryName;

  /// How much was left in the category before this purchase.
  final double categoryRemainingBefore;

  /// How much would remain in the category after this purchase.
  final double categoryRemainingAfter;

  /// How much distributable budget was left overall before this purchase.
  final double overallRemainingBefore;

  /// How much distributable budget would remain overall after this purchase.
  final double overallRemainingAfter;

  /// Short Estonian explanation shown to the user.
  final String explanation;
}
