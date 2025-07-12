import 'package:flutter/material.dart';

/// App color constants for consistent theming
class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF357ee9); // Indigo
  static const Color primaryLight = Color(0xFF669cf2);
  static const Color primaryDark = Color(0xFF176cdb);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color secondaryDark = Color(0xFF0891B2);

  // Accent colors
  static const Color accentColor = Color(0xFF10B981); // Emerald
  static const Color accentLight = Color(0xFF6EE7B7);
  static const Color accentDark = Color(0xFF059669);

  // Background colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Priority colors
  static const Color priorityLow = Color(0xFF22C55E);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);

  // Border colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);

  // Shadow colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x29000000);

  // Completed task colors
  static const Color completedTask = Color(0xFF9CA3AF);
  static const Color completedTaskBackground = Color(0xFFF3F4F6);

  // Divider
  static const Color divider = Color(0xFFE5E7EB);

  // Disabled
  static const Color disabled = Color(0xFFD1D5DB);

  // Overlay
  static const Color overlay = Color(0x4D000000);

  /// Get priority color based on priority level
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return priorityLow;
      case 2:
        return priorityMedium;
      case 3:
        return priorityHigh;
      default:
        return priorityLow;
    }
  }

  /// Get priority color with opacity
  static Color getPriorityColorWithOpacity(int priority, double opacity) {
    return getPriorityColor(priority).withOpacity(opacity);
  }
}
