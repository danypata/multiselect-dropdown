part of '../multi_dropdown.dart';

/// Manages focus nodes and navigation between dropdown elements
class KeyboardNavigationController<T> extends ChangeNotifier {
  /// Creates a keyboard navigation controller
  KeyboardNavigationController({
    required this.fieldFocusNode,
    required this.itemsFocusNode,
    required List<DropdownItem<T>> items,
    this.searchFocusNode,
  }) : _items = items;
  int? _focusedItemIndex;
  NavigationMode _currentMode = NavigationMode.field;
  final List<DropdownItem<T>> _items;

  // Focus nodes
  /// The focus node for the main field
  final FocusNode fieldFocusNode;

  /// The focus node for the search field
  final FocusNode? searchFocusNode;

  /// The focus node for the items list
  final FocusNode itemsFocusNode;

  // Getters
  /// Get current focus mode
  NavigationMode get currentMode => _currentMode;

  /// Get focused item index
  int? get focusedItemIndex => _focusedItemIndex;

  /// Check if search field is available
  bool get hasSearchField => searchFocusNode != null;

  // Navigation methods
  /// Move focus to search field
  void moveFocusToSearch() {
    if (searchFocusNode != null) {
      _currentMode = NavigationMode.search;
      searchFocusNode!.requestFocus();
      notifyListeners();
    }
  }

  /// Move focus to items list
  void moveFocusToItems([int? index]) {
    _currentMode = NavigationMode.items;
    _focusedItemIndex = index ?? 0;
    itemsFocusNode.requestFocus();
    notifyListeners();
  }

  /// Move focus to main field
  void moveFocusToField() {
    _currentMode = NavigationMode.field;
    _focusedItemIndex = null;
    fieldFocusNode.requestFocus();
    notifyListeners();
  }

  // Item navigation
  /// Move up in the list
  void moveUp() {
    if (_focusedItemIndex != null && _focusedItemIndex! > 0) {
      _focusedItemIndex = _focusedItemIndex! - 1;
      notifyListeners();
    }
  }

  /// Move down in the list
  void moveDown() {
    if (_focusedItemIndex != null && _focusedItemIndex! < _items.length - 1) {
      _focusedItemIndex = _focusedItemIndex! + 1;
      notifyListeners();
    }
  }

  /// Move to first item
  void moveToFirst() {
    _focusedItemIndex = 0;
    notifyListeners();
  }

  /// Move to last item
  void moveToLast() {
    _focusedItemIndex = _items.length - 1;
    notifyListeners();
  }

  /// Set focused index
  void setFocusedIndex(int? index) {
    _focusedItemIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    fieldFocusNode.dispose();
    searchFocusNode?.dispose();
    itemsFocusNode.dispose();
    super.dispose();
  }
}
