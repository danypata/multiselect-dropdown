part of '../multi_dropdown.dart';

/// Controller for the multiselect dropdown.
class MultiSelectController<T> extends ChangeNotifier {
  /// a flag to indicate whether the controller is initialized.
  bool _initialized = false;

  /// set initialized flag to true.
  void _initialize() {
    _initialized = true;
  }

  /// Set search enabled state
  void _setSearchEnabled(bool enabled) {
    _searchEnabled = enabled;
  }

  /// Set keyboard navigation configuration
  void _setKeyboardConfig(KeyboardNavigationConfig config) {
    _keyboardConfig = config;
  }

  List<DropdownItem<T>> _items = [];

  List<DropdownItem<T>> _filteredItems = [];

  String _searchQuery = '';

  // === ADD: Keyboard Navigation State Properties ===
  NavigationMode _currentFocusMode = NavigationMode.none;
  int? _currentFocusedItemIndex;
  DropdownItem<T>? _currentFocusedItem;
  bool _searchEnabled = false;
  KeyboardNavigationConfig _keyboardConfig = const KeyboardNavigationConfig();

  // === ADD: Focus Listeners ===
  final List<ValueChanged<bool>> _dropdownStateListeners = [];
  final List<ValueChanged<FocusChangeEvent<T>>> _focusChangeListeners = [];

  /// Gets the list of dropdown items.
  List<DropdownItem<T>> get items =>
      _searchQuery.isEmpty ? _items : _filteredItems;

  /// Gets the list of selected dropdown items.
  List<DropdownItem<T>> get selectedItems =>
      _items.where((element) => element.selected).toList();

  /// Get the list of selected dropdown item values.
  List<T> get _selectedValues => selectedItems.map((e) => e.value).toList();

  /// Gets the list of disabled dropdown items.
  List<DropdownItem<T>> get disabledItems =>
      _items.where((element) => element.disabled).toList();

  bool _open = false;

  /// Gets whether the dropdown is open.
  bool get isOpen => _open;

  bool _isDisposed = false;

  /// Gets whether the controller is disposed.
  bool get isDisposed => _isDisposed;

  // === ADD: Keyboard Navigation State Getters ===

  /// Check if dropdown is currently open
  bool get isDropdownOpen => _open;

  /// Check if dropdown is currently closed
  bool get isDropdownClosed => !_open;

  /// Get current focus mode
  NavigationMode get currentFocusMode => _currentFocusMode;

  /// Get currently focused item index (-1 if none)
  int? get currentFocusedItemIndex => _currentFocusedItemIndex;

  /// Get currently focused item (null if none)
  DropdownItem<T>? get currentFocusedItem => _currentFocusedItem;

  /// Check if main field has focus
  bool get isFieldFocused => _currentFocusMode == NavigationMode.field;

  /// Check if search field has focus
  bool get isSearchFocused => _currentFocusMode == NavigationMode.search;

  /// Check if any item has focus
  bool get hasItemFocus => _currentFocusMode == NavigationMode.items;

  /// Check if dropdown has any focus
  bool get hasAnyFocus => _currentFocusMode != NavigationMode.none;

  /// Gets the list of filtered dropdown items for keyboard navigation
  List<DropdownItem<T>> get filteredItems =>
      _searchQuery.isEmpty ? _items : _filteredItems;

  /// Check if search field is enabled
  bool get hasSearchField => _searchEnabled;

  /// on selection changed callback invoker.
  OnSelectionChanged<T>? _onSelectionChanged;

  /// on search changed callback invoker.
  OnSearchChanged? _onSearchChanged;

  /// sets the list of dropdown items.
  /// It replaces the existing list of dropdown items.
  void setItems(
    List<DropdownItem<T>> options, {
    bool notifySelection = true,
    bool shouldNotifyListeners = true,
  }) {
    _items
      ..clear()
      ..addAll(options);
    if (shouldNotifyListeners) {
      notifyListeners();
    }
    if (notifySelection) {
      _onSelectionChanged?.call(_selectedValues);
    }
  }

  /// Adds a dropdown item to the list of dropdown items.
  /// The [index] parameter is optional, and if provided, the item will be inserted at the specified index.
  void addItem(DropdownItem<T> option, {int index = -1}) {
    if (index == -1) {
      _items.add(option);
    } else {
      _items.insert(index, option);
    }
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// Adds a list of dropdown items to the list of dropdown items.
  void addItems(List<DropdownItem<T>> options) {
    _items.addAll(options);
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// clears all the selected items.
  void clearAll() {
    _items = _items
        .map(
          (element) =>
              element.selected ? element.copyWith(selected: false) : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// selects all the items.
  void selectAll() {
    _items = _items
        .map(
          (element) =>
              !element.selected ? element.copyWith(selected: true) : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// select the item at the specified index.
  ///
  /// The [index] parameter is the index of the item to select.
  void selectAtIndex(int index) {
    if (index < 0 || index >= _items.length) return;

    final item = _items[index];

    if (item.disabled || item.selected) return;

    selectWhere((element) => element == _items[index]);
  }

  /// deselects all the items.
  void toggleWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element)
              ? element.copyWith(selected: !element.selected)
              : element,
        )
        .toList();
    if (_searchQuery.isNotEmpty) {
      _filteredItems = _items
          .where(
            (item) =>
                item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// selects the items that satisfy the predicate.
  ///
  /// The [predicate] parameter is a function that takes a [DropdownItem] and returns a boolean.
  void selectWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element) && !element.selected
              ? element.copyWith(selected: true)
              : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  void _toggleOnly(DropdownItem<T> item) {
    _items = _items
        .map(
          (element) => element == item
              ? element.copyWith(selected: !element.selected)
              : element.copyWith(selected: false),
        )
        .toList();

    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// unselects the items that satisfy the predicate.
  ///
  /// The [predicate] parameter is a function that takes a [DropdownItem] and returns a boolean.
  void unselectWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element) && element.selected
              ? element.copyWith(selected: false)
              : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// disables the items that satisfy the predicate.
  ///
  /// The [predicate] parameter is a function that takes a [DropdownItem] and returns a boolean.
  void disableWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element) && !element.disabled
              ? element.copyWith(disabled: true)
              : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  /// shows the dropdown, if it is not already open.
  void openDropdown() {
    if (_open) return;

    _open = true;
    _notifyDropdownStateChange(true);

    // Auto-focus search field when dropdown opens (if available and enabled)
    // Note: Actual focus request will be handled by the widget after dropdown opens
    if (_keyboardConfig.autoFocusSearchOnOpen && hasSearchField) {
      _updateFocusMode(NavigationMode.search);
    } else if (_keyboardConfig.autoFocusSearchOnOpen) {
      // Focus first item if no search field but auto-focus is enabled
      if (filteredItems.isNotEmpty) {
        focusItemByIndex(0);
      }
    }

    notifyListeners();
  }

  /// hides the dropdown, if it is not already closed.
  void closeDropdown() {
    if (!_open) return;

    _open = false;
    _notifyDropdownStateChange(false);
    notifyListeners();
  }

  // === ADD: Focus Control Methods ===

  /// Focus the search field (opens dropdown if closed)
  void focusSearchField() {
    if (!_open) {
      openDropdown();
    }
    _updateFocusMode(NavigationMode.search);
  }

  /// Focus the next item in the list
  void focusNextItem() {
    if (_currentFocusedItemIndex == null) {
      focusItemByIndex(0);
    } else if (_currentFocusedItemIndex! < filteredItems.length - 1) {
      focusItemByIndex(_currentFocusedItemIndex! + 1);
    }
  }

  /// Focus the previous item in the list
  void focusPreviousItem() {
    if (_currentFocusedItemIndex == null) {
      focusItemByIndex(filteredItems.length - 1);
    } else if (_currentFocusedItemIndex! > 0) {
      focusItemByIndex(_currentFocusedItemIndex! - 1);
    }
  }

  /// Focus item by index
  void focusItemByIndex(int index) {
    if (index >= 0 && index < filteredItems.length) {
      if (!_open) {
        openDropdown();
      }
      _currentFocusedItemIndex = index;
      _currentFocusedItem = filteredItems[index];
      _updateFocusMode(NavigationMode.items);
    }
  }

  /// Focus item by value
  void focusItemByValue(T value) {
    final index = filteredItems.indexWhere((item) => item.value == value);
    if (index != -1) {
      focusItemByIndex(index);
    }
  }

  /// Focus first item
  void focusFirstItem() {
    if (filteredItems.isNotEmpty) {
      focusItemByIndex(0);
    }
  }

  /// Focus last item
  void focusLastItem() {
    if (filteredItems.isNotEmpty) {
      focusItemByIndex(filteredItems.length - 1);
    }
  }

  /// Toggle selection of currently focused item
  void toggleCurrentFocusedItem() {
    if (_currentFocusedItem != null) {
      toggleWhere((item) => item.value == _currentFocusedItem!.value);
    }
  }

  /// Focus the main dropdown field
  void focusField() {
    _updateFocusMode(NavigationMode.field);
  }

  /// Clear all focus from dropdown
  void clearDropdownFocus() {
    _currentFocusedItemIndex = null;
    _currentFocusedItem = null;
    _updateFocusMode(NavigationMode.none);
  }

  /// Sets the search query (public method)
  void setSearchQuery(String query) {
    _setSearchQuery(query);
  }

  /// Clears the search query (public method)
  void clearSearch() {
    _clearSearchQuery(notify: true);
  }

  // === ADD: Listener Management ===

  /// Add listener for dropdown state changes
  void addDropdownStateListener(ValueChanged<bool> listener) {
    _dropdownStateListeners.add(listener);
  }

  /// Remove dropdown state listener
  void removeDropdownStateListener(ValueChanged<bool> listener) {
    _dropdownStateListeners.remove(listener);
  }

  /// Add listener for focus changes
  void addFocusChangeListener(ValueChanged<FocusChangeEvent<T>> listener) {
    _focusChangeListeners.add(listener);
  }

  /// Remove focus change listener
  void removeFocusChangeListener(ValueChanged<FocusChangeEvent<T>> listener) {
    _focusChangeListeners.remove(listener);
  }

  // ignore: use_setters_to_change_properties
  void _setOnSelectionChange(OnSelectionChanged<T>? onSelectionChanged) {
    this._onSelectionChanged = onSelectionChanged;
  }

  // ignore: use_setters_to_change_properties
  void _setOnSearchChange(OnSearchChanged? onSearchChanged) {
    this._onSearchChanged = onSearchChanged;
  }

  // sets the search query.
  // The [query] parameter is the search query.
  void _setSearchQuery(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      _filteredItems = _items
          .where(
            (item) =>
                item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    _onSearchChanged?.call(query);
    notifyListeners();
  }

  // clears the search query.
  void _clearSearchQuery({bool notify = false}) {
    _searchQuery = '';
    if (notify) notifyListeners();
  }

  // === ADD: Internal Helper Methods ===

  void _updateFocusMode(NavigationMode newMode) {
    if (_currentFocusMode != newMode) {
      final oldMode = _currentFocusMode;
      final oldItemIndex = _currentFocusedItemIndex;
      final oldItem = _currentFocusedItem;

      _currentFocusMode = newMode;

      // Notify focus change listeners
      final event = FocusChangeEvent<T>(
        fromMode: oldMode,
        toMode: newMode,
        fromItemIndex: oldItemIndex,
        toItemIndex: _currentFocusedItemIndex,
        fromItem: oldItem,
        toItem: _currentFocusedItem,
        timestamp: DateTime.now(),
      );

      for (final listener in _focusChangeListeners) {
        listener(event);
      }

      notifyListeners();
    }
  }

  void _notifyDropdownStateChange(bool isOpen) {
    for (final listener in _dropdownStateListeners) {
      listener(isOpen);
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _dropdownStateListeners.clear();
    _focusChangeListeners.clear();
    super.dispose();
    _isDisposed = true;
  }

  @override
  String toString() {
    return 'MultiSelectController(options: $_items, open: $_open)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MultiSelectController<T> &&
        listEquals(other._items, _items) &&
        other._open == _open;
  }

  @override
  int get hashCode => _items.hashCode ^ _open.hashCode;
}
