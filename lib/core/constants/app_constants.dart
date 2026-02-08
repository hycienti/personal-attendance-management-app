/// Centralized application constants.
/// Avoid hard-coding values; add new constants here for reuse.
abstract final class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'ALU Assistant';
  static const String appTagline = 'Academic Excellence';

  // Layout
  static const double maxContentWidth = 430;
  static const double bottomNavHeight = 80;
  static const double bottomNavSafePadding = 24;
  static const double screenPadding = 16;
  static const double cardBorderRadius = 12;
  static const double inputHeight = 56;
  static const double buttonHeight = 56;

  // Animation
  static const Duration animationShort = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);

  // Pagination / Lists
  static const int defaultPageSize = 20;
  static const int maxTitleLength = 100;
  static const int maxNotesLength = 1000;

  // Date / Time
  static const String defaultTimeFormat = 'HH:mm';
  static const String dateFormatShort = 'MMM d, y';
  static const String dateFormatDisplay = 'EEEE, MMM d';
  static const String timeDisplayFormat = 'h:mm a';

  static const double buttonBorderRadius = 12;
  static const double inputBorderRadius = 12;
}
