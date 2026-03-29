// Widget and state-logic tests for core SafeSpender flows.
//
// These tests cover:
//   1. PurchaseCheckState business logic (canEvaluate, hasCategories)
//   2. PurchaseCheckScreen rendering with provider overrides

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safespender/features/purchase_check/domain/models/purchase_check_result.dart';
import 'package:safespender/features/purchase_check/domain/models/purchase_risk_status.dart';
import 'package:safespender/features/purchase_check/presentation/providers/purchase_check_notifier.dart';
import 'package:safespender/features/purchase_check/presentation/purchase_check_screen.dart';
import 'package:safespender/features/setup/domain/models/budget_category.dart';

// ── Fake notifier for widget tests ───────────────────────────────────────────

class _FakePurchaseCheckNotifier extends PurchaseCheckNotifier {
  _FakePurchaseCheckNotifier(this._fixedState);
  final PurchaseCheckState _fixedState;

  @override
  Future<PurchaseCheckState> build() async => _fixedState;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final helperDate = DateTime(2025, 1, 1);

BudgetCategory testCat(String name, {int id = 1}) => BudgetCategory(
      id: id,
      name: name,
      allocationPercent: 30,
      plannedAmount: 300,
      isDefault: false,
      sortOrder: 0,
      createdAt: helperDate,
      updatedAt: helperDate,
    );

Widget buildScreen(PurchaseCheckState state) => ProviderScope(
      overrides: [
        purchaseCheckProvider
            .overrideWith(() => _FakePurchaseCheckNotifier(state)),
      ],
      child: const MaterialApp(home: PurchaseCheckScreen()),
    );

// ═════════════════════════════════════════════════════════════════════════════

void main() {
  // ── PurchaseCheckState unit logic ─────────────────────────────────────────

  group('PurchaseCheckState.canEvaluate', () {
    test('false when not configured', () {
      const state = PurchaseCheckState.notConfigured();
      expect(state.canEvaluate, isFalse);
    });

    test('false when no categories', () {
      const state = PurchaseCheckState.noCategories();
      expect(state.canEvaluate, isFalse);
    });

    test('false when no category selected', () {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
        amountInput: '50',
        selectedCategoryId: null,
      );
      expect(state.canEvaluate, isFalse);
    });

    test('false when amount is empty', () {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
        amountInput: '',
        selectedCategoryId: 1,
      );
      expect(state.canEvaluate, isFalse);
    });

    test('false when amount is zero', () {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
        amountInput: '0',
        selectedCategoryId: 1,
      );
      expect(state.canEvaluate, isFalse);
    });

    test('false when evaluation is already in progress', () {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
        amountInput: '50',
        selectedCategoryId: 1,
        isEvaluating: true,
      );
      expect(state.canEvaluate, isFalse);
    });

    test('true when category selected and valid positive amount', () {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
        amountInput: '50',
        selectedCategoryId: 1,
      );
      expect(state.canEvaluate, isTrue);
    });

    test('accepts comma as decimal separator', () {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
        amountInput: '12,50',
        selectedCategoryId: 1,
      );
      expect(state.canEvaluate, isTrue);
    });
  });

  group('PurchaseCheckState.hasCategories', () {
    test('false when not configured', () {
      expect(const PurchaseCheckState.notConfigured().hasCategories, isFalse);
    });

    test('false when no categories', () {
      expect(const PurchaseCheckState.noCategories().hasCategories, isFalse);
    });

    test('true when categories are loaded', () {
      final state = PurchaseCheckState.ready(categories: [testCat('Toit')]);
      expect(state.hasCategories, isTrue);
    });
  });

  // ── PurchaseCheckScreen widget tests ──────────────────────────────────────

  group('PurchaseCheckScreen', () {
    testWidgets('shows setup required message when not configured', (tester) async {
      await tester.pumpWidget(
        buildScreen(const PurchaseCheckState.notConfigured()),
      );
      await tester.pump();

      expect(find.textContaining('eelarve'), findsWidgets);
    });

    testWidgets('shows categories message when configured but no categories', (tester) async {
      await tester.pumpWidget(
        buildScreen(const PurchaseCheckState.noCategories()),
      );
      await tester.pump();

      expect(find.textContaining('kategoori'), findsWidgets);
    });

    testWidgets('shows form header when ready with categories', (tester) async {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit'), testCat('Transport', id: 2)],
      );
      await tester.pumpWidget(buildScreen(state));
      await tester.pump();

      expect(find.text('Ostu hindamine'), findsOneWidget);
    });

    testWidgets('shows a chip for each loaded category', (tester) async {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit'), testCat('Transport', id: 2)],
      );
      await tester.pumpWidget(buildScreen(state));
      await tester.pump();

      expect(find.text('Toit'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('evaluate button is disabled when no input', (tester) async {
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
      );
      await tester.pumpWidget(buildScreen(state));
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows "Turvaline" result label when result is safe', (tester) async {
      final result = PurchaseCheckResult(
        status: PurchaseRiskStatus.safe,
        purchaseAmount: 50,
        categoryName: 'Toit',
        categoryRemainingBefore: 200,
        categoryRemainingAfter: 150,
        overallRemainingBefore: 700,
        overallRemainingAfter: 650,
        explanation: 'Pärast seda ostu jääks kategoorias «Toit» alles 150,00 €.',
      );
      final state = PurchaseCheckState.ready(
        categories: [testCat('Toit')],
        selectedCategoryId: 1,
        amountInput: '50',
        result: result,
      );

      await tester.pumpWidget(buildScreen(state));
      await tester.pump();

      expect(find.text('Turvaline'), findsOneWidget);
    });
  });
}
