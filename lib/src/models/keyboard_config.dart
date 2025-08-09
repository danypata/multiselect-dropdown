part of '../multi_dropdown.dart';

/// Configuration for keyboard navigation behavior
class KeyboardNavigationConfig {
  /// Creates a keyboard navigation configuration
  const KeyboardNavigationConfig({
    this.enableTabNavigation = true,
    this.enableArrowKeyNavigation = true,
    this.enableEnterToSelect = true,
    this.enableSpaceToSelect = true,
    this.enableEscapeToClose = true,
    this.autoFocusSearchOnOpen = true,
    this.cycleThroughItems = true,
    this.trapFocusInDropdown = true,
  });

  /// Enable Tab navigation between elements
  final bool enableTabNavigation;

  /// Enable arrow key navigation
  final bool enableArrowKeyNavigation;

  /// Enable Enter to select items
  final bool enableEnterToSelect;

  /// Enable Space to select items
  final bool enableSpaceToSelect;

  /// Enable Escape to close dropdown
  final bool enableEscapeToClose;

  /// Auto-focus search when dropdown opens
  final bool autoFocusSearchOnOpen;

  /// Cycle through items with Tab navigation
  final bool cycleThroughItems;

  /// Trap focus within dropdown context
  final bool trapFocusInDropdown;
}
