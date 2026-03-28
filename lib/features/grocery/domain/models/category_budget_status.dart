enum CategoryBudgetStatus {

  underBudget,

  onTrack,

  /// not yet exceeded but usage is >= 85% risk.
  nearLimit,

  overBudget,
}
