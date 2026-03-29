import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../setup/domain/models/budget_category.dart';
import '../domain/models/purchase_check_result.dart';
import '../domain/models/purchase_risk_status.dart';
import 'providers/purchase_check_notifier.dart';

class PurchaseCheckScreen extends ConsumerStatefulWidget {
  const PurchaseCheckScreen({super.key});

  @override
  ConsumerState<PurchaseCheckScreen> createState() =>
      _PurchaseCheckScreenState();
}

class _PurchaseCheckScreenState extends ConsumerState<PurchaseCheckScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkAsync = ref.watch(purchaseCheckProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: checkAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => _EmptyLayout(
            icon: Icons.error_outline,
            title: 'Midagi läks valesti',
            message: e.toString(),
          ),
          data: (state) {
            if (!state.isConfigured) {
              return const _EmptyLayout(
                icon: Icons.tune_outlined,
                title: 'Seadistus puudub',
                message:
                    'Ostu hindamiseks lõpeta esmalt eelarve seadistamine.',
              );
            }
            if (!state.hasCategories) {
              return const _EmptyLayout(
                icon: Icons.category_outlined,
                title: 'Kategooriaid pole',
                message:
                    'Lisa seadistuses kulukategooriad, et ostu hinnata.',
              );
            }
            return _FormBody(
              formState: state,
              amountController: _amountController,
            );
          },
        ),
      ),
    );
  }
}

// ── Form body ─────────────────────────────────────────────────────────────────

class _FormBody extends ConsumerWidget {
  const _FormBody({
    required this.formState,
    required this.amountController,
  });

  final PurchaseCheckState formState;
  final TextEditingController amountController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              _ScreenHeader(),
              const SizedBox(height: 28),

              // ── Amount input ──────────────────────────────────────────
              _SectionLabel('Planeeritud summa'),
              const SizedBox(height: 12),
              _AmountField(
                controller: amountController,
                onChanged: (v) =>
                    ref.read(purchaseCheckProvider.notifier).updateAmount(v),
              ),
              const SizedBox(height: 28),

              // ── Category picker ───────────────────────────────────────
              _SectionLabel('Kategooria'),
              const SizedBox(height: 14),
              _CategoryChips(
                categories: formState.categories,
                selectedId: formState.selectedCategoryId,
                onSelect: (id) =>
                    ref.read(purchaseCheckProvider.notifier).selectCategory(id),
              ),
              const SizedBox(height: 32),

              // ── Result card ───────────────────────────────────────────
              if (formState.result != null) ...[
                _ResultCard(result: formState.result!),
                const SizedBox(height: 16),
              ],

              // ── Inline error ──────────────────────────────────────────
              if (formState.errorMessage != null) ...[
                _ErrorBanner(message: formState.errorMessage!),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),

        // ── Evaluate button ───────────────────────────────────────────
        _EvaluateButton(
          canEvaluate: formState.canEvaluate,
          isEvaluating: formState.isEvaluating,
          onPressed: () =>
              ref.read(purchaseCheckProvider.notifier).evaluate(),
        ),
      ],
    );
  }
}

// ── Screen header ─────────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ostu hindamine',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF021C36),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sisesta summa ja kategooria, et näha, kas ost on turvaline.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ── Amount field ──────────────────────────────────────────────────────────────

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '€',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '0,00',
                hintStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<BudgetCategory> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((c) {
        final selected = selectedId == c.id;
        return GestureDetector(
          onTap: () => onSelect(c.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.divider,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              c.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final PurchaseCheckResult result;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusTheme.from(result.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status row ────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(colors.icon, size: 20, color: colors.accent),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tulemus',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.accent.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    _statusLabel(result.status),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Numbers row ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NumberItem(
                    label: 'Kategoorias alles',
                    value: _fmtSigned(result.categoryRemainingAfter),
                    color: result.categoryRemainingAfter < 0
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _NumberItem(
                    label: 'Üldine varu alles',
                    value: _fmtSigned(result.overallRemainingAfter),
                    color: result.overallRemainingAfter < 0
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Explanation ───────────────────────────────────────────
          Text(
            result.explanation,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: colors.accent.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(PurchaseRiskStatus s) {
    switch (s) {
      case PurchaseRiskStatus.safe:
        return 'Turvaline';
      case PurchaseRiskStatus.borderline:
        return 'Piiri peal';
      case PurchaseRiskStatus.notRecommended:
        return 'Ei ole soovitatav';
    }
  }

  String _fmtSigned(double amount) {
    final abs = amount.abs().toStringAsFixed(2).replaceAll('.', ',');
    return amount < 0 ? '−$abs €' : '$abs €';
  }
}

class _NumberItem extends StatelessWidget {
  const _NumberItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.border,
    );
  }
}

// ── Evaluate button ───────────────────────────────────────────────────────────

class _EvaluateButton extends StatelessWidget {
  const _EvaluateButton({
    required this.canEvaluate,
    required this.isEvaluating,
    required this.onPressed,
  });

  final bool canEvaluate;
  final bool isEvaluating;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0),
            AppColors.background,
          ],
          stops: const [0.0, 0.35],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: (canEvaluate && !isEvaluating) ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.divider,
            foregroundColor: Colors.white,
            disabledForegroundColor: AppColors.textMuted,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          icon: isEvaluating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.price_check_outlined, size: 20),
          label: Text(
            isEvaluating ? 'Arvutan...' : 'Hinda ostu',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 16, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / missing-data state ────────────────────────────────────────────────

class _EmptyLayout extends StatelessWidget {
  const _EmptyLayout({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.inputFill,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status theming ────────────────────────────────────────────────────────────

class _StatusTheme {
  const _StatusTheme({
    required this.accent,
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.icon,
  });

  factory _StatusTheme.from(PurchaseRiskStatus status) {
    switch (status) {
      case PurchaseRiskStatus.safe:
        return const _StatusTheme(
          accent: Color(0xFF006763),
          background: Color(0xFFECF9F7),
          border: Color(0xFFB2E8E3),
          iconBackground: Color(0xFFBFE7E3),
          icon: Icons.check_circle_outline,
        );
      case PurchaseRiskStatus.borderline:
        return const _StatusTheme(
          accent: Color(0xFF9A5C00),
          background: Color(0xFFFFF8EE),
          border: Color(0xFFFFDEA0),
          iconBackground: Color(0xFFFFE9C7),
          icon: Icons.warning_amber_rounded,
        );
      case PurchaseRiskStatus.notRecommended:
        return const _StatusTheme(
          accent: Color(0xFFBA1A1A),
          background: Color(0xFFFFF0F0),
          border: Color(0xFFFFB4B4),
          iconBackground: Color(0xFFFFDAD6),
          icon: Icons.cancel_outlined,
        );
    }
  }

  final Color accent;
  final Color background;
  final Color border;
  final Color iconBackground;
  final IconData icon;
}
