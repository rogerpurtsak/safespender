import '../models/purchase_check_result.dart';
import '../models/purchase_risk_status.dart';

/// Pure domain service: evaluates whether a planned purchase is safe given
/// the current monthly budget state.
///
/// Assessment thresholds (MVP-pragmatic):
///   SAFE            – purchase fits in category AND leaves a healthy cushion
///                     both per-category and overall
///   BORDERLINE      – purchase fits but leaves very little room
///                     (category < max(15 €, 10 % of planned) OR
///                      overall < 8 % of distributable)
///   NOT RECOMMENDED – purchase exceeds category remaining, OR pushes the
///                     overall distributable budget negative
class PurchaseRiskEvaluator {
  const PurchaseRiskEvaluator();

  PurchaseCheckResult evaluate({
    required double purchaseAmount,
    required String categoryName,
    required double categoryPlannedAmount,
    required double categorySpentAmount,
    required double distributableAmount,
    required double totalSpentThisMonth,
  }) {
    final categoryRemainingBefore = categoryPlannedAmount - categorySpentAmount;
    final overallRemainingBefore = distributableAmount - totalSpentThisMonth;
    final categoryRemainingAfter = categoryRemainingBefore - purchaseAmount;
    final overallRemainingAfter = overallRemainingBefore - purchaseAmount;

    final PurchaseRiskStatus status;
    final String explanation;

    if (categoryRemainingAfter < 0) {
      // Purchase exceeds what's left in the chosen category.
      status = PurchaseRiskStatus.notRecommended;
      final shortfall = (purchaseAmount - categoryRemainingBefore)
          .abs()
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      explanation =
          'See ost ületaks kategooria «$categoryName» allesjäänud eelarve '
          '${_fmt(categoryRemainingBefore)} võrra $shortfall €. '
          'Hetkel ei ole soovitatav.';
    } else if (overallRemainingAfter < 0) {
      // Purchase fits the category but breaks the overall distributable budget.
      status = PurchaseRiskStatus.notRecommended;
      explanation =
          'See ost viiks kuu üldise jaotussumma miinusesse. '
          'Praeguse kuu seisu põhjal ei ole see ost soovitatav.';
    } else {
      // Purchase technically fits — check how tight it leaves things.
      final categoryBuffer =
          (categoryPlannedAmount * 0.10).clamp(15.0, 50.0);
      final overallBuffer = distributableAmount * 0.08;

      final categoryTight = categoryRemainingAfter < categoryBuffer;
      final overallTight = overallRemainingAfter < overallBuffer;

      if (categoryTight || overallTight) {
        status = PurchaseRiskStatus.borderline;
        if (categoryTight) {
          explanation =
              'See ost mahub eelarvesse, kuid jätab kategooriasse «$categoryName» '
              'väga väikese varu (${_fmt(categoryRemainingAfter)}). '
              'Ole edaspidiste kuludega ettevaatlik.';
        } else {
          explanation =
              'See ost mahub eelarvesse, kuid kuu üldine jaotussumma varu '
              'jääb väga napiks (${_fmt(overallRemainingAfter)}). '
              'Kaalu hoolikalt.';
        }
      } else {
        status = PurchaseRiskStatus.safe;
        explanation =
            'Pärast seda ostu jääks kategoorias «$categoryName» alles '
            '${_fmt(categoryRemainingAfter)} ja kuu üldseis püsib '
            'turvalises tsoonis.';
      }
    }

    return PurchaseCheckResult(
      status: status,
      purchaseAmount: purchaseAmount,
      categoryName: categoryName,
      categoryRemainingBefore: categoryRemainingBefore,
      categoryRemainingAfter: categoryRemainingAfter,
      overallRemainingBefore: overallRemainingBefore,
      overallRemainingAfter: overallRemainingAfter,
      explanation: explanation,
    );
  }

  String _fmt(double amount) {
    final abs = amount.abs().toStringAsFixed(2).replaceAll('.', ',');
    return amount < 0 ? '−$abs €' : '$abs €';
  }
}
