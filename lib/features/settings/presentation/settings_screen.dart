import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/app_state_screen.dart';
import '../../../features/setup/domain/models/budget_category.dart';
import 'providers/settings_notifier.dart';
import 'providers/settings_state.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsNotifierProvider.notifier).loadCurrentSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    ref.listen(settingsNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        notifier.clearMessages();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        notifier.clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.85),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Seaded',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Halda oma eelarve eelistusi ja jaotust',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? AppStateScreen.loading()
          : !state.hasProfile
              ? AppStateScreen.setupRequired(
                  onSetup: () => context.go('/setup'),
                  body:
                      'Seadete kasutamiseks sisesta esmalt eelarve alus — sissetulek, püsikulud ja kategooriad.',
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        children: [
                          _sectionLabel('Eelarve seaded'),
                          const SizedBox(height: 12),
                          _BudgetSettingsCard(
                              state: state, notifier: notifier),
                          const SizedBox(height: 24),
                          _CategorySectionHeader(state: state),
                          const SizedBox(height: 12),
                          _CategoryListCard(
                              state: state, notifier: notifier),
                          const SizedBox(height: 8),
                          _AddCategoryButton(notifier: notifier),
                          const SizedBox(height: 24),
                          _sectionLabel('Eelistused'),
                          const SizedBox(height: 12),
                          _NotificationsCard(
                              state: state, notifier: notifier),
                          const SizedBox(height: 24),
                          _DataSecurityCard(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    _SaveButton(state: state, notifier: notifier),
                  ],
                ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}


class _BudgetSettingsCard extends StatelessWidget {
  final SettingsState state;
  final SettingsNotifier notifier;

  const _BudgetSettingsCard(
      {required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: [
        _TappableRow(
          label: 'Puhver',
          subtitle: 'Igakuine reservfond',
          value:
              '${state.safetyBuffer.toStringAsFixed(2).replaceAll('.', ',')} ${state.currencySymbol}',
          onTap: () => _showBufferSheet(context),
        ),
        const _RowDivider(),
        _TappableRow(
          label: 'Valuuta',
          subtitle: 'Vaikimisi valuuta tehingutele',
          value: state.currencyLabel,
          onTap: () => _showCurrencySheet(context),
        ),
      ],
    );
  }

  void _showBufferSheet(BuildContext context) {
    final controller = TextEditingController(
      text: state.safetyBuffer > 0
          ? state.safetyBuffer.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: 'Turvapuhver',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summa, mida iga kuu kõrvale paned',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _AmountField(controller: controller),
            const SizedBox(height: 24),
            _SheetSaveButton(
              label: 'Kinnita',
              onTap: () {
                notifier.updateSafetyBufferInput(controller.text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => _BottomSheetContainer(
          title: 'Valuuta',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in [
                ('EUR', 'Euro', '€'),
                ('USD', 'Ameerika dollar', '\$'),
                ('GBP', 'Naelsterling', '£'),
              ])
                _CurrencyOption(
                  code: option.$1,
                  name: option.$2,
                  symbol: option.$3,
                  isSelected: state.currencyCode == option.$1,
                  onTap: () {
                    notifier.updateCurrencyCode(option.$1);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class _CategorySectionHeader extends StatelessWidget {
  final SettingsState state;

  const _CategorySectionHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = state.totalAllocatedPercent;
    final isOver = pct > 100;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'KATEGOORIATE HALDUS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOver
                  ? AppColors.errorBg
                  : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'KOKKU: ${pct.toStringAsFixed(0)}%',
              style: TextStyle(
                color: isOver ? AppColors.error : AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _CategoryListCard extends StatelessWidget {
  final SettingsState state;
  final SettingsNotifier notifier;

  const _CategoryListCard(
      {required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final cats = state.categories;
    if (cats.isEmpty) {
      return _Card(children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Kategooriad puuduvad.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      ]);
    }

    final opacities = [1.0, 0.65, 0.45, 0.28, 0.15];

    return _Card(
      children: [
        for (int i = 0; i < cats.length; i++) ...[
          if (i > 0) const _RowDivider(),
          _CategoryRow(
            category: cats[i],
            accentOpacity: opacities[i % opacities.length],
            onEdit: () => _showEditSheet(context, i, cats[i]),
          ),
        ],
        const _RowDivider(),
        _AllocationBar(categories: cats),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Kokku jaotatud: ${state.totalAllocatedPercent.toStringAsFixed(0)}%'
            '${state.unallocatedPercent > 0 ? '  •  Jaotamata: ${state.unallocatedPercent.toStringAsFixed(0)}%' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditSheet(
      BuildContext context, int index, BudgetCategory category) {
    final nameCtrl = TextEditingController(text: category.name);
    double localPercent = category.allocationPercent;

    final maxPercent =
        category.allocationPercent + state.unallocatedPercent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => _BottomSheetContainer(
          title: category.isDefault
              ? category.name
              : 'Muuda kategooriat',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!category.isDefault) ...[
                const Text(
                  'Nimi',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Osakaal',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    '${localPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: localPercent,
                min: 0,
                max: maxPercent > 0 ? maxPercent : 100,
                divisions: (maxPercent > 0 ? maxPercent : 100).round(),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primarySoft,
                onChanged: (v) =>
                    setModalState(() => localPercent = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!category.isDefault)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          notifier.removeCategory(index);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side:
                              const BorderSide(color: AppColors.error),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Kustuta'),
                      ),
                    ),
                  if (!category.isDefault) const SizedBox(width: 12),
                  Expanded(
                    child: _SheetSaveButton(
                      label: 'Salvesta',
                      onTap: () {
                        if (!category.isDefault) {
                          notifier.updateCategoryName(
                              index, nameCtrl.text);
                        }
                        notifier.updateCategoryAllocationPercent(
                            index, localPercent);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final BudgetCategory category;
  final double accentOpacity;
  final VoidCallback onEdit;

  const _CategoryRow({
    required this.category,
    required this.accentOpacity,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForCategory(category.name),
              color: AppColors.primary.withValues(alpha: accentOpacity),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${category.allocationPercent.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String name) {
    final l = name.toLowerCase();
    if (l.contains('toit') || l.contains('söök') || l.contains('restoran')) {
      return Icons.restaurant;
    }
    if (l.contains('transport') ||
        l.contains('auto') ||
        l.contains('kütus') ||
        l.contains('buss')) {
      return Icons.directions_car;
    }
    if (l.contains('üür') ||
        l.contains('kodu') ||
        l.contains('maja') ||
        l.contains('kommunaal')) {
      return Icons.home;
    }
    if (l.contains('meelelahutus') ||
        l.contains('hobi') ||
        l.contains('vaba')) {
      return Icons.confirmation_number;
    }
    if (l.contains('tervis') || l.contains('arst') || l.contains('apteek')) {
      return Icons.favorite_border;
    }
    if (l.contains('riided') || l.contains('mood') || l.contains('rõivad')) {
      return Icons.checkroom;
    }
    if (l.contains('haridus') || l.contains('kool') || l.contains('kursus')) {
      return Icons.school;
    }
    if (l.contains('säästud') ||
        l.contains('hoiused') ||
        l.contains('investee')) {
      return Icons.savings;
    }
    return Icons.label_outline;
  }
}

class _AllocationBar extends StatelessWidget {
  final List<BudgetCategory> categories;

  const _AllocationBar({required this.categories});

  static const _opacities = [1.0, 0.65, 0.45, 0.28, 0.15];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 6,
          child: Row(
            children: categories.asMap().entries.map((e) {
              final pct = e.value.allocationPercent / 100;
              if (pct <= 0) return const SizedBox.shrink();
              return Flexible(
                flex: (pct * 1000).round(),
                child: Container(
                  color: AppColors.primary
                      .withValues(alpha: _opacities[e.key % _opacities.length]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}


class _AddCategoryButton extends StatelessWidget {
  final SettingsNotifier notifier;

  const _AddCategoryButton({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Lisa uus kategooria',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: 'Uus kategooria',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategooria nimi',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputFill,
                hintText: 'nt. Spordiklubi',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            _SheetSaveButton(
              label: 'Lisa kategooria',
              onTap: () {
                notifier.addCategory(ctrl.text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}


class _NotificationsCard extends StatelessWidget {
  final SettingsState state;
  final SettingsNotifier notifier;

  const _NotificationsCard(
      {required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Märguanded',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Saate lubada või keelata meeldetuletus-stiilis teavitused',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: state.notificationsEnabled,
                onChanged: notifier.toggleNotifications,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _DataSecurityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.security,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Andmete turvalisus',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Teie andmeid hoitakse turvaliselt ainult teie seadmes. '
                    'Rakendus ei saada teie finantsandmeid välis-serveritesse.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SaveButton extends StatelessWidget {
  final SettingsState state;
  final SettingsNotifier notifier;

  const _SaveButton({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed:
              state.isSaving || !state.isFormValid ? null : notifier.saveChanges,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: state.isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Salvesta muudatused',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}


class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _TappableRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  const _TappableRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F3F7),
      indent: 16,
      endIndent: 16,
    );
  }
}

class _BottomSheetContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheetContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;

  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '€',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: '0,00',
              hintStyle: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetSaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SheetSaveButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final String code;
  final String name;
  final String symbol;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                symbol,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                '$name ($code)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
