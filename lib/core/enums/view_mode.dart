enum ViewMode { day, month }

extension ViewModeExtension on ViewMode {
  String get displayName {
    switch (this) {
      case ViewMode.day:
        return 'Día';
      case ViewMode.month:
        return 'Mes';
    }
  }
}
