part of '../multi_dropdown.dart';

/// Handles keyboard events for the dropdown
class KeyboardEventHandler<T> {
  /// Creates a keyboard event handler
  KeyboardEventHandler({
    required this.navigationController,
    required this.dropdownController,
    required this.singleSelect,
    this.trapFocusInDropdown = true,
  });

  /// Navigation controller for managing focus
  final KeyboardNavigationController<T> navigationController;

  /// Dropdown controller for managing state
  final MultiSelectController<T> dropdownController;

  /// Whether this is single select mode
  final bool singleSelect;

  /// Whether to trap focus within dropdown
  final bool trapFocusInDropdown;

  /// Handle keyboard events
  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (navigationController.currentMode) {
      case NavigationMode.field:
        return _handleFieldKeys(event);
      case NavigationMode.search:
        return _handleSearchKeys(event);
      case NavigationMode.items:
        return _handleItemKeys(event);
      case NavigationMode.none:
        return KeyEventResult.ignored;
    }
  }

  KeyEventResult _handleFieldKeys(KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (!dropdownController.isDropdownOpen) {
        dropdownController.openDropdown();
        if (navigationController.hasSearchField) {
          navigationController.moveFocusToSearch();
        } else {
          navigationController.moveFocusToItems(0);
        }
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (dropdownController.isDropdownOpen) {
        navigationController.moveFocusToItems(0);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (dropdownController.isDropdownOpen) {
        dropdownController.closeDropdown();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleSearchKeys(KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // Universal close - clears search and closes dropdown
      dropdownController
        ..clearSearch()
        ..closeDropdown();
      navigationController.moveFocusToField();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      // Move to first filtered item if search has results
      final filteredItems = dropdownController.filteredItems;
      if (filteredItems.isNotEmpty) {
        navigationController.moveFocusToItems(0);
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      if (trapFocusInDropdown) {
        if (!HardwareKeyboard.instance.isShiftPressed) {
          // CRITICAL: Tab from search goes directly to first item
          // This prevents Tab from leaving dropdown context
          navigationController.moveFocusToItems(0);
          return KeyEventResult.handled;
        } else {
          // Shift+Tab goes back to field
          navigationController.moveFocusToField();
          return KeyEventResult.handled;
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      navigationController.moveFocusToItems(0);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleItemKeys(KeyDownEvent event) {
    final currentIndex = navigationController.focusedItemIndex ?? 0;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // Universal close key - works from any focus state
      dropdownController.closeDropdown();
      navigationController.moveFocusToField();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      navigationController.moveUp();
      _updateControllerFocus();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      navigationController.moveDown();
      _updateControllerFocus();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      navigationController.moveToFirst();
      _updateControllerFocus();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      navigationController.moveToLast();
      _updateControllerFocus();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      // Always toggles selection, keeps dropdown open
      _toggleCurrentItem();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      // Behavior depends on selection mode
      if (singleSelect) {
        // Single-select: select and close
        _selectCurrentItem();
        dropdownController.closeDropdown();
        navigationController.moveFocusToField();
      } else {
        // Multi-select: toggle selection, stay open
        _toggleCurrentItem();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      if (trapFocusInDropdown) {
        final totalItems = dropdownController.filteredItems.length;

        if (!HardwareKeyboard.instance.isShiftPressed) {
          // Forward tab
          if (currentIndex < totalItems - 1) {
            // Move to next item
            navigationController.setFocusedIndex(currentIndex + 1);
            _updateControllerFocus();
          } else {
            // Cycle back to search field (or field if no search)
            if (navigationController.hasSearchField) {
              navigationController.moveFocusToSearch();
            } else {
              navigationController.moveFocusToField();
            }
          }
          return KeyEventResult.handled;
        } else {
          // Shift+tab (backward)
          if (currentIndex > 0) {
            // Move to previous item
            navigationController.setFocusedIndex(currentIndex - 1);
            _updateControllerFocus();
          } else {
            // Move back to search field (or field if no search)
            if (navigationController.hasSearchField) {
              navigationController.moveFocusToSearch();
            } else {
              navigationController.moveFocusToField();
            }
          }
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void _toggleCurrentItem() {
    final index = navigationController.focusedItemIndex;
    if (index != null && index < dropdownController.filteredItems.length) {
      dropdownController.toggleCurrentFocusedItem();
    }
  }

  void _selectCurrentItem() {
    final index = navigationController.focusedItemIndex;
    if (index != null && index < dropdownController.filteredItems.length) {
      final item = dropdownController.filteredItems[index];
      dropdownController.selectWhere((i) => i.value == item.value);
    }
  }

  void _updateControllerFocus() {
    final index = navigationController.focusedItemIndex;
    if (index != null) {
      dropdownController.focusItemByIndex(index);
    }
  }
}
