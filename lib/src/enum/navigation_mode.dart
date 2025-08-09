part of '../multi_dropdown.dart';

/// Represents the current focus location within the dropdown
enum NavigationMode {
  /// Main dropdown field has focus
  field,

  /// Search field has focus (if search is enabled)
  search,

  /// A dropdown item has focus
  items,

  /// No focus within dropdown
  none,
}
