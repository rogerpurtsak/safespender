import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import 'providers/setup_notifier.dart';
import 'providers/setup_state.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SetupHeader(),
              SizedBox(height: AppSpacing.xl),
              SizedBox(height: AppSpacing.xl),
              SizedBox(height: AppSpacing.xl),
              _IntroSection(),
              SizedBox(height: AppSpacing.xl),
              _SetupFormCard(),
              SizedBox(height: AppSpacing.xxl),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.successBg,
          child: Text(
            'BB',
            style: AppTextStyles.button.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Bigbank',
          style: AppTextStyles().brand,
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.textPrimary,
          splashRadius: 22,
        ),
      ],
    );
  }
}

class _IntroSection extends StatelessWidget {
  const _IntroSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Eelarve\nseadistamine',
            style: AppTextStyles().introHeader,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sisesta oma põhiandmed ja määra kategooriad, et rakendus saaks sinu eelarvet targemalt jälgida.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SetupFormCard extends ConsumerStatefulWidget {
  const _SetupFormCard();

  @override
  ConsumerState<_SetupFormCard> createState() => _SetupFormCardState();
}

class _SetupFormCardState extends ConsumerState<_SetupFormCard> {
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController fixedExpensesController =
      TextEditingController();
  final TextEditingController bufferController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final state = ref.read(setupNotifierProvider);
    incomeController.text = state.monthlyIncomeInput;
    fixedExpensesController.text = state.monthlyFixedExpensesInput;
    bufferController.text = state.safetyBufferInput;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(setupNotifierProvider.notifier).loadSavedSetupIfExists();
    });
  }

  @override
  void dispose() {
    incomeController.dispose();
    fixedExpensesController.dispose();
    bufferController.dispose();
    newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupNotifierProvider);
    final notifier = ref.read(setupNotifierProvider.notifier);

    ref.listen<SetupState>(setupNotifierProvider, (_, next) {
      if (next.hasCompletedSetup && mounted) {
        context.go('/');
      }
    });

    final distributableAmount = notifier.distributableAmount;
    final totalAllocatedPercent = notifier.totalAllocatedPercent;
    final unallocatedPercent = notifier.unallocatedPercent;
    final previewCategories = notifier.previewCategories;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
        notifier.clearMessages();
      }

      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!)),
        );
        notifier.clearMessages();
      }
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MoneyField(
            label: 'Igakuine sissetulek',
            hintText: '0.00',
            controller: incomeController,
            onChanged: notifier.updateMonthlyIncomeInput,
          ),
          const SizedBox(height: AppSpacing.xl),
          _MoneyField(
            label: 'Püsikulud',
            hintText: '0.00',
            controller: fixedExpensesController,
            onChanged: notifier.updateMonthlyFixedExpensesInput,
          ),
          const SizedBox(height: AppSpacing.xl),
          _MoneyField(
            label: 'Soovitud puhver',
            hintText: '0.00',
            controller: bufferController,
            onChanged: notifier.updateSafetyBufferInput,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Planeeritav raha',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${distributableAmount.toStringAsFixed(2)} €',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Muuda kategooriate osakaale slideritega. Rakendus arvutab summad ise.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Lisa kategooria',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newCategoryController,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Näiteks Transport',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: () {
                  notifier.addCategory(newCategoryController.text);

                  final latestState = ref.read(setupNotifierProvider);
                  if (latestState.errorMessage == null) {
                    newCategoryController.clear();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                child: const Text('Lisa'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                'Kategooriad',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${totalAllocatedPercent.toStringAsFixed(0)} / 100%',
                style: AppTextStyles.label.copyWith(
                  color: totalAllocatedPercent > 100
                      ? AppColors.error
                      : AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(state.categories.length, (index) {
            final category = state.categories[index];
            final previewCategory = previewCategories[index];
            final maxPercent = notifier.maxAllowedPercentFor(index);

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardHighlight,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: category.isDefault
                              ? AppColors.primary
                              : AppColors.info,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          category.name,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${previewCategory.plannedAmount.toStringAsFixed(0)} €',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton(
                        onPressed: () => notifier.removeCategory(index),
                        icon: const Icon(Icons.close),
                        color: category.isDefault
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Osakaal ${category.allocationPercent.toStringAsFixed(0)}% • kuni ${maxPercent.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodySmall,
                  ),
                  Slider(
                    value: category.allocationPercent,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: category.isDefault
                        ? AppColors.primary
                        : AppColors.info,
                    onChanged: (value) {
                      notifier.updateCategoryAllocationPercent(
                        index: index,
                        newPercent: value,
                      );
                    },
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaotus kokku',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Jaotatav raha: ${distributableAmount.toStringAsFixed(2)} €',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Jaotatud: ${totalAllocatedPercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Jaotamata: ${unallocatedPercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
            onPressed: state.isSaving
                ? null
                : () async {
                    final success = await notifier.saveSetup();
                    if (success && context.mounted) {
                      context.go('/');
                    }
                  },
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 11, 99, 93),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xl,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
              ),
              child: Text(
                state.isSaving ? 'Salvestan...' : 'Salvesta seaded',
                style: AppTextStyles.button,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'ANDMED ON TURVALISELT KRÜPTEERITUD.',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _MoneyField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Text(
                '€',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}