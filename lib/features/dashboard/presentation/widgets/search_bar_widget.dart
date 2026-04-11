import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class _C {
  _C._();
  static const Color primary = Color(0xFF0D9E5C);
  static const Color primaryDark = Color(0xFF087A45);
  static const Color primaryLight = Color(0xFFE8F8F0);
  // static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F9FC);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color iconGrey = Color(0xFFB0B7C3);
  static const Color red = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D9E5C), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ExpandableFocusSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const ExpandableFocusSearchBar({super.key, this.onChanged, this.onFilterTap});

  @override
  State<ExpandableFocusSearchBar> createState() =>
      _ExpandableFocusSearchBarState();
}

class _ExpandableFocusSearchBarState extends State<ExpandableFocusSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;

  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  final List<String> _recentSearches = [
    'Galaxy Futsal',
    'Baneshwor Indoor',
    'Near Lalitpur',
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });

    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main search bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 50,
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(_isFocused ? 10 : 10),
            border: Border.all(
              color: _isFocused
                  ? LightColor.secondaryColor.withOpacity(0.4)
                  : LightColor.borderColor.withOpacity(0.6),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? LightColor.secondaryColor.withOpacity(0.1)
                    : LightColor.shadowColor.withOpacity(0.03),
                blurRadius: _isFocused ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  _isFocused ? Icons.search_rounded : Icons.search_rounded,
                  key: ValueKey(_isFocused),
                  color: _isFocused ? LightColor.secondaryColor : LightColor.hintTextColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    color: LightColor.primaryTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: 'Where do you want to play?',
                    hintStyle: TextStyle(
                      color: LightColor.hintTextColor,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (_hasText)
                _buildIconButton(
                  Icons.close_rounded,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _controller.clear();
                  },
                  color: _C.textSecondary,
                  bg: _C.borderLight,
                ),
              SizedBox(width: 2),
              _buildIconButton(
                Icons.tune_rounded,
                onTap: widget.onFilterTap,
                color: Colors.white,
                isGradient: true,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        _recentSearches.isEmpty
            ? SizedBox.shrink()
            : SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: LightColor.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: LightColor.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Searches',
                              style: TextStyle(
                                color: _C.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  color: _C.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._recentSearches.map((s) => _buildRecentItem(s)),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildRecentItem(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, color: _C.iconGrey, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: _C.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.north_west_rounded, color: _C.iconGrey, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    VoidCallback? onTap,
    Color color = _C.iconGrey,
    Color bg = Colors.transparent,
    bool isGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          gradient: isGradient ? _C.primaryGradient : null,
          color: isGradient ? null : bg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isGradient
              ? [
                  BoxShadow(
                    color: _C.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
