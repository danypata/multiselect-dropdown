part of '../multi_dropdown.dart';

/// Event fired when focus changes within the dropdown
class FocusChangeEvent<T> {
  /// Creates a focus change event
  FocusChangeEvent({
    required this.fromMode,
    required this.toMode,
    required this.timestamp,
    this.fromItemIndex,
    this.toItemIndex,
    this.fromItem,
    this.toItem,
  });

  /// The focus mode before the change
  final NavigationMode fromMode;

  /// The focus mode after the change
  final NavigationMode toMode;

  /// The item index before the change (if any)
  final int? fromItemIndex;

  /// The item index after the change (if any)
  final int? toItemIndex;

  /// The item before the change (if any)
  final DropdownItem<T>? fromItem;

  /// The item after the change (if any)
  final DropdownItem<T>? toItem;

  /// The timestamp when the change occurred
  final DateTime timestamp;

  /// Whether the focus is moving to the field
  bool get isMovingToField => toMode == NavigationMode.field;

  /// Whether the focus is moving to the search field
  bool get isMovingToSearch => toMode == NavigationMode.search;

  /// Whether the focus is moving to items
  bool get isMovingToItems => toMode == NavigationMode.items;

  /// Whether the focused item has changed
  bool get isItemChanged => fromItemIndex != toItemIndex;

  /// Whether focus is leaving the dropdown
  bool get isLeavingDropdown => toMode == NavigationMode.none;

  /// Whether focus is entering the dropdown
  bool get isEnteringDropdown => fromMode == NavigationMode.none;
}
