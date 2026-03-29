import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Shared full-screen state widget for loading, error, empty, and setup-required states.
///
/// Use the static factory methods for common cases:
///   AppStateScreen.loading()
///   AppStateScreen.error(message: '...', onRetry: () => ...)
///   AppStateScreen.empty(title: '...', body: '...')
///   AppStateScreen.setupRequired(onSetup: () => ...)
///
/// The [setupRequired] variant is visually distinct: the icon uses the primary
/// teal colour and always renders a primary CTA button, signalling that the
/// missing state is a prerequisite rather than an error or data gap.
class AppStateScreen extends StatelessWidget {
  const AppStateScreen._loading()
      : _showLoading = true,
        icon = null,
        title = '',
        body = null,
        iconColor = null,
        iconBackground = null,
        actionLabel = null,
        onAction = null;

  const AppStateScreen({
    super.key,
    this.icon,
    required this.title,
    this.body,
    this.iconColor,
    this.iconBackground,
    this.actionLabel,
    this.onAction,
  }) : _showLoading = false;

  final bool _showLoading;
  final IconData? icon;
  final String title;
  final String? body;
  final Color? iconColor;
  final Color? iconBackground;
  final String? actionLabel;
  final VoidCallback? onAction;

  // ── Named factory constructors ────────────────────────────────────────────

  /// Calm centered loading spinner.
  static AppStateScreen loading() => const AppStateScreen._loading();

  /// Error state with optional retry action.
  static AppStateScreen error({
    String message = 'Andmete laadimine ebaõnnestus.',
    VoidCallback? onRetry,
  }) =>
      AppStateScreen(
        icon: Icons.error_outline_rounded,
        title: 'Midagi läks valesti',
        body: message,
        iconColor: AppColors.error,
        iconBackground: AppColors.errorBg,
        actionLabel: onRetry != null ? 'Proovi uuesti' : null,
        onAction: onRetry,
      );

  /// Generic empty/no-data state.
  static AppStateScreen empty({
    required String title,
    required String body,
    IconData icon = Icons.inbox_outlined,
  }) =>
      AppStateScreen(
        icon: icon,
        title: title,
        body: body,
        iconColor: AppColors.textSecondary,
        iconBackground: AppColors.inputFill,
      );

  /// Setup-required state — visually distinct from plain empty.
  ///
  /// Uses the primary teal colour and always shows a CTA button leading to setup.
  static AppStateScreen setupRequired({
    required VoidCallback onSetup,
    String title = 'Seadistus puudub',
    String body =
        'Selle vaate kasutamiseks sisesta esmalt kuine eelarve alus.',
  }) =>
      AppStateScreen(
        icon: Icons.account_balance_wallet_outlined,
        title: title,
        body: body,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primarySoft,
        actionLabel: 'Ava seadistus',
        onAction: onSetup,
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconBackground ?? AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                body!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
