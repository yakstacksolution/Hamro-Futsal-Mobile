import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.icon,
    required this.options,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
  });

  final String labelText;
  final IconData icon;
  final List<String> options;
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final bool enabled;

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fillColor = LightColor.background.withValues(alpha: 0.9);

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.15),
      );
    }

    return Focus(
      onFocusChange: (value) {
        setState(() => isFocused = value);
      },
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        onChanged: widget.enabled
            ? (value) {
                setState(() => selectedValue = value);
                widget.onChanged?.call(value);
              }
            : null,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: LightColor.titleTextColor,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: widget.enabled ? LightColor.darkgrey : LightColor.grey,
          size: 22,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: Icon(widget.icon, color: LightColor.darkgrey, size: 20),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: fillColor,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: LightColor.darkgrey,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: LightColor.grey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: border(LightColor.lightGrey),
          focusedBorder: border(theme.colorScheme.primary),
          disabledBorder: border(LightColor.lightGrey),
          border: border(LightColor.lightGrey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: widget.options.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: LightColor.titleTextColor,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';

// class CustomDropdown extends StatefulWidget {
//   final List<String> options;
//   final String? initialValue;
//   final String hintText;
//   final ValueChanged<String>? onChanged;
//   final Color activeColor;
//   final Color inactiveColor;

//   const CustomDropdown({
//     super.key,
//     required this.options,
//     this.initialValue,
//     this.hintText = 'Select option',
//     this.onChanged,
//     this.activeColor = LightColor.primaryGreen,
//     this.inactiveColor = LightColor.grey,
//   });

//   @override
//   State<CustomDropdown> createState() => _CustomDropdownState();
// }

// class _CustomDropdownState extends State<CustomDropdown>
//     with SingleTickerProviderStateMixin {
//   late String? _selected;
//   bool _isOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     _selected = widget.initialValue;
//   }

//   void _toggleDropdown() {
//     setState(() => _isOpen = !_isOpen);
//   }

//   void _selectItem(String value) {
//     setState(() {
//       _selected = value;
//       _isOpen = false;
//     });
//     widget.onChanged?.call(value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: _toggleDropdown,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 220),
//             curve: Curves.easeInOut,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                 color: _isOpen || _selected != null
//                     ? widget.activeColor.withOpacity(0.45)
//                     : Colors.transparent,
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: (_isOpen || _selected != null)
//                       ? widget.activeColor.withOpacity(0.14)
//                       : Colors.black.withOpacity(0.04),
//                   blurRadius: (_isOpen || _selected != null) ? 12 : 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 18,
//                   height: 18,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _selected != null
//                         ? widget.activeColor
//                         : Colors.transparent,
//                     border: Border.all(
//                       color: _selected != null
//                           ? widget.activeColor
//                           : widget.inactiveColor,
//                       width: _selected != null ? 0 : 2,
//                     ),
//                   ),
//                   child: _selected != null
//                       ? const Center(
//                           child: Icon(
//                             Icons.check,
//                             size: 12,
//                             color: Colors.white,
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: AnimatedDefaultTextStyle(
//                     duration: const Duration(milliseconds: 200),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: _selected != null
//                           ? FontWeight.w600
//                           : FontWeight.w400,
//                       color: _selected != null
//                           ? const Color(0xFF2D3A1A)
//                           : Colors.grey.shade600,
//                     ),
//                     child: Text(_selected ?? widget.hintText),
//                   ),
//                 ),
//                 AnimatedRotation(
//                   turns: _isOpen ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 220),
//                   child: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: _selected != null
//                         ? widget.activeColor
//                         : widget.inactiveColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         AnimatedSize(
//           duration: const Duration(milliseconds: 220),
//           curve: Curves.easeInOut,
//           child: _isOpen
//               ? Container(
//                   margin: const EdgeInsets.only(top: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: widget.activeColor.withOpacity(0.18),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: widget.activeColor.withOpacity(0.08),
//                         blurRadius: 14,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: widget.options.map((option) {
//                       final bool isSelected = _selected == option;

//                       return InkWell(
//                         borderRadius: BorderRadius.circular(12),
//                         onTap: () => _selectItem(option),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 180),
//                           curve: Curves.easeInOut,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? widget.activeColor.withOpacity(0.08)
//                                 : Colors.transparent,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 width: 18,
//                                 height: 18,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: isSelected
//                                       ? widget.activeColor
//                                       : Colors.transparent,
//                                   border: Border.all(
//                                     color: isSelected
//                                         ? widget.activeColor
//                                         : widget.inactiveColor,
//                                     width: isSelected ? 0 : 2,
//                                   ),
//                                 ),
//                                 child: isSelected
//                                     ? const Center(
//                                         child: Icon(
//                                           Icons.check,
//                                           size: 12,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     : null,
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   option,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: isSelected
//                                         ? FontWeight.w600
//                                         : FontWeight.w400,
//                                     color: isSelected
//                                         ? const Color(0xFF2D3A1A)
//                                         : Colors.grey.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 )
//               : const SizedBox.shrink(),
//         ),
//       ],
//     );
//   }
// }
