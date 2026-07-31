import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/helper/recent_search_store.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class ExpandableFocusSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  /// Fired when the user commits a search (keyboard "search", tapping a recent
  /// entry, or clearing the field — which submits an empty string).
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final int filterCount;

  const ExpandableFocusSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.filterCount = 0,
  });

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

  final RecentSearchStore _recentStore = RecentSearchStore.instance;

  @override
  void initState() {
    super.initState();
    _recentStore.load();
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

  /// Commits a search: persists a non-empty term, syncs the field, dismisses
  /// the keyboard and notifies the parent. An empty term resets the search.
  void _submit(String raw) {
    final String term = raw.trim();
    if (term.isNotEmpty) {
      _recentStore.add(term);
      if (_controller.text != term) {
        _controller.text = term;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: term.length),
        );
      }
    }
    _focusNode.unfocus();
    widget.onSubmitted?.call(term);
  }

  void _clear() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onSubmitted?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: AppDimens.sizeX50,
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(
              _isFocused ? AppDimens.radiusX10 : AppDimens.radiusX10,
            ),
            border: Border.all(
              color: _isFocused
                  ? LightColor.secondaryColor.withValues(alpha: 0.4)
                  : LightColor.greyBorderColor,
              width: _isFocused ? 1 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? LightColor.secondaryColor.withValues(alpha: 0.1)
                    : LightColor.shadowColor.withValues(alpha: 0.05),
                blurRadius: _isFocused
                    ? AppDimens.radiusX20
                    : AppDimens.radiusX12,
                offset: const Offset(0, AppDimens.sizeX4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: AppDimens.sizeX16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  _isFocused ? Icons.search_rounded : Icons.search_rounded,
                  key: ValueKey(_isFocused),
                  color: _isFocused
                      ? LightColor.secondaryColor
                      : LightColor.hintTextColor,
                  size: AppDimens.sizeX22,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submit,
                  cursorColor: LightColor.primaryTextColor,
                  cursorHeight: AppDimens.sizeX20,
                  cursorWidth: 1.5,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(color: LightColor.primaryTextColor),
                  decoration: InputDecoration(
                    filled: false,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: StringConstants.whereDoYouWantToPlay,

                    hintStyle: FutsalTheme.getTextTheme(context).bodyTextMedium
                        ?.copyWith(
                          color: LightColor.hintTextColor,
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
                  onTap: _clear,
                  color: LightColor.whiteColor,
                  bg: LightColor.greyBorderColor,
                ),
              SizedBox(width: AppDimens.sizeX2),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildIconButton(
                    Icons.tune_rounded,
                    onTap: widget.onFilterTap,
                    color: LightColor.whiteColor,
                    isGradient: true,
                  ),
                  if (widget.filterCount > 0)
                    Positioned(
                      right: -2,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimens.sizeX4),
                        constraints: const BoxConstraints(
                          minWidth: AppDimens.sizeX16,
                          minHeight: AppDimens.sizeX16,
                        ),
                        decoration: BoxDecoration(
                          color: LightColor.redColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: LightColor.cardColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${widget.filterCount}',
                          textAlign: TextAlign.center,
                          style: FutsalTheme.getTextTheme(context)
                              .bodyMiniSubTitle
                              ?.copyWith(
                                color: LightColor.whiteColor,
                                fontWeight: FontWeight.w800,
                                fontSize: AppDimens.sizeX10,
                                height: 1,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppDimens.sizeX8),
            ],
          ),
        ),

        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _recentStore.searches,
              builder: (context, recents, _) {
                if (recents.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(top: AppDimens.sizeX8),
                  padding: const EdgeInsets.all(AppDimens.paddingX16),
                  decoration: BoxDecoration(
                    color: LightColor.cardColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: AppDimens.radiusX6,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            StringConstants.recentSearches,
                            style: FutsalTheme.getTextTheme(context)
                                .bodyTextMedium
                                ?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                ),
                          ),
                          GestureDetector(
                            onTap: _recentStore.clear,
                            child: Text(
                              StringConstants.clearAll,
                              style: FutsalTheme.getTextTheme(context)
                                  .bodyTextSmall
                                  ?.copyWith(color: LightColor.redColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sizeX12),
                      ...recents.map((s) => _buildRecentItem(s)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentItem(String text) {
    return GestureDetector(
      onTap: () => _submit(text),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.sizeX10),

        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: LightColor.iconGrey,
              size: AppDimens.sizeX18,
            ),
            const SizedBox(width: AppDimens.sizeX12),
            Expanded(
              child: Text(
                text,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _recentStore.remove(text);
              },
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(AppDimens.sizeX4),
                child: Icon(
                  Icons.close_rounded,
                  color: LightColor.iconGrey,
                  size: AppDimens.sizeX16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    VoidCallback? onTap,
    Color color = LightColor.iconGrey,
    Color bg = LightColor.transparentColor,
    bool isGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimens.sizeX36,
        height: AppDimens.sizeX36,
        margin: const EdgeInsets.only(left: AppDimens.sizeX2),
        decoration: BoxDecoration(
          color: LightColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
        ),
        child: Icon(icon, color: color, size: AppDimens.sizeX20),
      ),
    );
  }
}
