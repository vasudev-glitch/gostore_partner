import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ✅ Responsive Size Helpers
class AppSize {
  static double blockWidth(BuildContext context) => MediaQuery.of(context).size.width / 100;
  static double blockHeight(BuildContext context) => MediaQuery.of(context).size.height / 100;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}

/// ✅ Core Text Styles (used inside AppTextStyle)
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

/// ✅ Theme-aware Text Style Wrappers
class AppTextStyle {
  static TextStyle headingLarge(BuildContext context) =>
      AppTextStyles.sectionTitle.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle headingMedium(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle body(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    color: Theme.of(context).textTheme.bodyMedium?.color,
  );

  static TextStyle caption(BuildContext context) => GoogleFonts.poppins(
    fontSize: 12,
    color: Theme.of(context).hintColor,
  );

  static TextStyle badge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onPrimary,
  );
}

/// ✅ Padding & Spacing Constants
class AppPaddings {
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0);
  static const EdgeInsets card = EdgeInsets.all(16.0);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// ✅ Rounded Corner Radii
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
}

/// ✅ Button Styles (Material 3 Compliant)
class AppButtonStyles {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    elevation: 3,
  );

  static final ButtonStyle secondary = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    textStyle: AppTextStyles.button,
    side: const BorderSide(color: Colors.black54),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    elevation: 1,
  );

  static final ButtonStyle large = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.button.copyWith(fontSize: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    elevation: 4,
  );
}

/// ✅ Card Decorations
class AppDecorations {
  static BoxDecoration elevatedCard(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: AppRadius.card,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
