import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ✅ Responsive Size Helpers
class AppSize {
  static double blockWidth(BuildContext context) => MediaQuery.of(context).size.width / 100;
  static double blockHeight(BuildContext context) => MediaQuery.of(context).size.height / 100;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}

/// ✅ App-wide Text Styles
class AppTextStyles {
  static TextStyle appBar = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

/// ✅ Unified TextStyle Accessors (used by admin widgets)
class AppTextStyle {
  static TextStyle headingLarge(BuildContext context) => AppTextStyles.sectionTitle;
  static TextStyle body(BuildContext context) => Theme.of(context).textTheme.bodyMedium!;
  static TextStyle caption(BuildContext context) => Theme.of(context).textTheme.labelSmall!;
}

/// ✅ Padding Constants
class AppPaddings {
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0);
}

/// ✅ Spacing Constants
class AppSpacing {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
}

/// ✅ Border Radius Constants
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
}

/// ✅ Button Styles
class AppButtonStyles {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final ButtonStyle secondary = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    textStyle: AppTextStyles.button,
    side: const BorderSide(color: Colors.black54),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final ButtonStyle large = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.button.copyWith(fontSize: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
