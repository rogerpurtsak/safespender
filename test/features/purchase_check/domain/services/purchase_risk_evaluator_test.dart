import 'package:flutter_test/flutter_test.dart';
import 'package:safespender/features/purchase_check/domain/models/purchase_risk_status.dart';
import 'package:safespender/features/purchase_check/domain/services/purchase_risk_evaluator.dart';

void main() {
  const evaluator = PurchaseRiskEvaluator();

  // Convenience helper — evaluates with sensible defaults that caller can override.
  PurchaseRiskStatus evalStatus({
    double purchaseAmount = 50,
    String categoryName = 'Toit',
    double categoryPlannedAmount = 300,
    double categorySpentAmount = 100,
    double distributableAmount = 1000,
    double totalSpentThisMonth = 300,
  }) =>
      evaluator
          .evaluate(
            purchaseAmount: purchaseAmount,
            categoryName: categoryName,
            categoryPlannedAmount: categoryPlannedAmount,
            categorySpentAmount: categorySpentAmount,
            distributableAmount: distributableAmount,
            totalSpentThisMonth: totalSpentThisMonth,
          )
          .status;

  // ── NOT_RECOMMENDED ─────────────────────────────────────────────────────────

  group('notRecommended', () {
    test('when purchase exceeds category remaining', () {
      // remaining = 300 - 250 = 50; purchase = 60 → categoryRemainingAfter = -10
      expect(
        evalStatus(
          purchaseAmount: 60,
          categoryPlannedAmount: 300,
          categorySpentAmount: 250,
        ),
        PurchaseRiskStatus.notRecommended,
      );
    });

    test('when purchase exactly depletes and would go negative in category', () {
      // remaining = 300 - 200 = 100; purchase = 101 → -1
      expect(
        evalStatus(
          purchaseAmount: 101,
          categoryPlannedAmount: 300,
          categorySpentAmount: 200,
        ),
        PurchaseRiskStatus.notRecommended,
      );
    });

    test('when purchase fits category but breaks overall distributable', () {
      // categoryRemaining = 300 - 0 = 300; overallRemaining = 1000 - 950 = 50; purchase = 60
      // overallRemainingAfter = 50 - 60 = -10 → not recommended
      expect(
        evalStatus(
          purchaseAmount: 60,
          categoryPlannedAmount: 300,
          categorySpentAmount: 0,
          distributableAmount: 1000,
          totalSpentThisMonth: 950,
        ),
        PurchaseRiskStatus.notRecommended,
      );
    });

    test('explanation mentions category name when category is the blocker', () {
      final result = evaluator.evaluate(
        purchaseAmount: 200,
        categoryName: 'Meelelahutus',
        categoryPlannedAmount: 150,
        categorySpentAmount: 0,
        distributableAmount: 1000,
        totalSpentThisMonth: 0,
      );
      expect(result.status, PurchaseRiskStatus.notRecommended);
      expect(result.explanation, contains('Meelelahutus'));
    });
  });

  // ── BORDERLINE ──────────────────────────────────────────────────────────────

  group('borderline', () {
    test('when category remaining after purchase is below buffer (10% of planned, min 15)', () {
      // planned = 200, buffer = max(15, 200*0.10) = 20
      // remaining before = 200 - 0 = 200; after = 200 - 185 = 15 < 20 → borderline
      expect(
        evalStatus(
          purchaseAmount: 185,
          categoryPlannedAmount: 200,
          categorySpentAmount: 0,
          distributableAmount: 2000,
          totalSpentThisMonth: 0,
        ),
        PurchaseRiskStatus.borderline,
      );
    });

    test('when category buffer floor (15 €) is used for small planned amounts', () {
      // planned = 50, 10% = 5 → clamped to 15
      // remaining = 50 - 0 = 50; after = 50 - 40 = 10 < 15 → borderline
      expect(
        evalStatus(
          purchaseAmount: 40,
          categoryPlannedAmount: 50,
          categorySpentAmount: 0,
          distributableAmount: 2000,
          totalSpentThisMonth: 0,
        ),
        PurchaseRiskStatus.borderline,
      );
    });

    test('when overall remaining after purchase is below 8% of distributable', () {
      // distributable = 1000, overallBuffer = 80
      // overallRemaining before = 1000 - 840 = 160; after = 160 - 100 = 60 < 80 → borderline
      // category is fine: planned=500, spent=0, after=400 > buffer
      expect(
        evalStatus(
          purchaseAmount: 100,
          categoryPlannedAmount: 500,
          categorySpentAmount: 0,
          distributableAmount: 1000,
          totalSpentThisMonth: 840,
        ),
        PurchaseRiskStatus.borderline,
      );
    });

    test('explanation mentions category name when category is tight', () {
      final result = evaluator.evaluate(
        purchaseAmount: 40,
        categoryName: 'Transport',
        categoryPlannedAmount: 50,
        categorySpentAmount: 0,
        distributableAmount: 2000,
        totalSpentThisMonth: 0,
      );
      expect(result.status, PurchaseRiskStatus.borderline);
      expect(result.explanation, contains('Transport'));
    });
  });

  // ── SAFE ────────────────────────────────────────────────────────────────────

  group('safe', () {
    test('when purchase leaves comfortable room in both category and overall', () {
      // remaining = 300 - 100 = 200; after = 200 - 50 = 150
      // buffer = max(15, 300*0.10) = 30; 150 > 30 → category OK
      // overall: 1000 - 300 = 700; after = 700 - 50 = 650; buffer = 80; 650 > 80 → OK
      expect(
        evalStatus(
          purchaseAmount: 50,
          categoryPlannedAmount: 300,
          categorySpentAmount: 100,
          distributableAmount: 1000,
          totalSpentThisMonth: 300,
        ),
        PurchaseRiskStatus.safe,
      );
    });

    test('when purchase is very small relative to budget', () {
      expect(
        evalStatus(
          purchaseAmount: 1,
          categoryPlannedAmount: 500,
          categorySpentAmount: 0,
          distributableAmount: 2000,
          totalSpentThisMonth: 0,
        ),
        PurchaseRiskStatus.safe,
      );
    });

    test('explanation mentions category name on safe result', () {
      final result = evaluator.evaluate(
        purchaseAmount: 10,
        categoryName: 'Toit',
        categoryPlannedAmount: 300,
        categorySpentAmount: 0,
        distributableAmount: 1000,
        totalSpentThisMonth: 0,
      );
      expect(result.status, PurchaseRiskStatus.safe);
      expect(result.explanation, contains('Toit'));
    });
  });

  // ── Result fields ────────────────────────────────────────────────────────────

  group('result fields', () {
    test('categoryRemainingBefore equals planned minus spent', () {
      final result = evaluator.evaluate(
        purchaseAmount: 50,
        categoryName: 'Toit',
        categoryPlannedAmount: 300,
        categorySpentAmount: 100,
        distributableAmount: 1000,
        totalSpentThisMonth: 300,
      );
      expect(result.categoryRemainingBefore, closeTo(200.0, 0.01));
    });

    test('categoryRemainingAfter equals remaining minus purchase', () {
      final result = evaluator.evaluate(
        purchaseAmount: 50,
        categoryName: 'Toit',
        categoryPlannedAmount: 300,
        categorySpentAmount: 100,
        distributableAmount: 1000,
        totalSpentThisMonth: 300,
      );
      expect(result.categoryRemainingAfter, closeTo(150.0, 0.01));
    });

    test('overallRemainingBefore equals distributable minus total spent', () {
      final result = evaluator.evaluate(
        purchaseAmount: 50,
        categoryName: 'Toit',
        categoryPlannedAmount: 300,
        categorySpentAmount: 100,
        distributableAmount: 1000,
        totalSpentThisMonth: 300,
      );
      expect(result.overallRemainingBefore, closeTo(700.0, 0.01));
    });

    test('overallRemainingAfter equals overall remaining minus purchase', () {
      final result = evaluator.evaluate(
        purchaseAmount: 50,
        categoryName: 'Toit',
        categoryPlannedAmount: 300,
        categorySpentAmount: 100,
        distributableAmount: 1000,
        totalSpentThisMonth: 300,
      );
      expect(result.overallRemainingAfter, closeTo(650.0, 0.01));
    });

    test('purchaseAmount is preserved in result', () {
      final result = evaluator.evaluate(
        purchaseAmount: 123.45,
        categoryName: 'Toit',
        categoryPlannedAmount: 300,
        categorySpentAmount: 0,
        distributableAmount: 1000,
        totalSpentThisMonth: 0,
      );
      expect(result.purchaseAmount, closeTo(123.45, 0.001));
    });
  });

  // ── Edge cases ───────────────────────────────────────────────────────────────

  group('edge cases', () {
    test('zero purchase amount is safe when budget has room', () {
      expect(
        evalStatus(
          purchaseAmount: 0,
          categoryPlannedAmount: 300,
          categorySpentAmount: 0,
          distributableAmount: 1000,
          totalSpentThisMonth: 0,
        ),
        PurchaseRiskStatus.safe,
      );
    });

    test('category buffer is capped at 50 € for very large planned amounts', () {
      // planned = 2000, 10% = 200 → clamped to 50
      // remaining = 2000; after = 2000 - 1960 = 40 < 50 → borderline
      expect(
        evalStatus(
          purchaseAmount: 1960,
          categoryPlannedAmount: 2000,
          categorySpentAmount: 0,
          distributableAmount: 10000,
          totalSpentThisMonth: 0,
        ),
        PurchaseRiskStatus.borderline,
      );
    });
  });
}
