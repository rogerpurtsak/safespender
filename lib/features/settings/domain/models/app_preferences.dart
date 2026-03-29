class AppPreferences {
  final bool notificationsEnabled;

  const AppPreferences({
    this.notificationsEnabled = false,
  });

  AppPreferences copyWith({bool? notificationsEnabled}) {
    return AppPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  static const _keyNotifications = 'notifications_enabled';

  Map<String, String> toKeyValueMap() {
    return {
      _keyNotifications: notificationsEnabled ? '1' : '0',
    };
  }

  factory AppPreferences.fromKeyValueMap(Map<String, String> map) {
    return AppPreferences(
      notificationsEnabled: map[_keyNotifications] == '1',
    );
  }

  static const AppPreferences defaults = AppPreferences();
}
