part of '../multi_dropdown.dart';

/// Wraps dropdown content to trap focus within the dropdown
class DropdownFocusScope extends StatefulWidget {
  /// Creates a dropdown focus scope
  const DropdownFocusScope({
    required this.child,
    Key? key,
    this.trapFocus = true,
    this.onEscape,
  }) : super(key: key);

  /// The child widget to wrap
  final Widget child;

  /// Whether to trap focus within the scope
  final bool trapFocus;

  /// Callback when escape key is pressed
  final VoidCallback? onEscape;

  @override
  State<DropdownFocusScope> createState() => _DropdownFocusScopeState();
}

class _DropdownFocusScopeState extends State<DropdownFocusScope> {
  late FocusScopeNode _scopeNode;
  late FocusNode _keyboardListenerNode;

  @override
  void initState() {
    super.initState();
    _scopeNode = FocusScopeNode(
      debugLabel: 'DropdownFocusScope',
    );
    _keyboardListenerNode = FocusNode(
      debugLabel: 'DropdownKeyboardListener',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trapFocus) {
      return FocusScope(
        node: _scopeNode,
        child: KeyboardListener(
          focusNode: _keyboardListenerNode,
          onKeyEvent: _handleKeyEvent,
          child: widget.child,
        ),
      );
    }
    return widget.child;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onEscape?.call();
      }
    }
  }

  @override
  void dispose() {
    _scopeNode.dispose();
    _keyboardListenerNode.dispose();
    super.dispose();
  }
}
