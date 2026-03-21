import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

class CustomRadioGroup extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const CustomRadioGroup({
    super.key,
    required this.options,
    this.initialValue,
    this.onChanged,
    this.activeColor = LightColor.primaryGreen,
    this.inactiveColor = LightColor.grey,
  });

  @override
  State<CustomRadioGroup> createState() => _CustomRadioGroupState();
}

class _CustomRadioGroupState extends State<CustomRadioGroup> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.options.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 6,
              right: index == widget.options.length - 1 ? 0 : 6,
            ),
            child: CustomRadioButton(
              label: label,
              isSelected: _selected == label,
              activeColor: widget.activeColor,
              inactiveColor: widget.inactiveColor,
              onTap: () {
                setState(() => _selected = label);
                widget.onChanged?.call(label);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Single Custom Radio Button Tile
// ─────────────────────────────────────────────────────────────────

class CustomRadioButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const CustomRadioButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor.withOpacity(0.5)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? activeColor : inactiveColor,
                  width: isSelected ? 0 : 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(width: 10),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF2D3A1A)
                    : Colors.grey.shade600,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
