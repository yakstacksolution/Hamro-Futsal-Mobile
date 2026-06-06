import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, this.focusNode});

  final ValueChanged<String> onSend;
  final FocusNode? focusNode;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();

  bool get _canSend => _ctrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onSend(text);
    _ctrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingX12,
          AppDimens.paddingX6,
          AppDimens.paddingX12,
          AppDimens.paddingX12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 46,
                  maxHeight: 118,
                ),
                decoration: BoxDecoration(
                  color: LightColor.cardColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX24),
                  border: Border.all(color: LightColor.whiteColor, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: LightColor.shadowColor,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PillIcon(
                      icon: Icons.emoji_emotions_outlined,
                      onTap: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        focusNode: widget.focusNode,
                        onChanged: (_) => setState(() {}),
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: LightColor.secondaryColor,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Message…',
                          hintStyle: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: 13.5,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                    _PillIcon(icon: Icons.attach_file_rounded, onTap: () {}),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimens.paddingX8),
            AnimatedScale(
              scale: _canSend ? 1 : 0.92,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _canSend
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            LightColor.secondaryColor,
                            LightColor.secondaryColor.withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                  color: _canSend ? null : LightColor.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: _canSend
                          ? LightColor.secondaryColor.withValues(alpha: 0.35)
                          : LightColor.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _canSend ? _send : null,
                    child: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: _canSend
                          ? LightColor.whiteColor
                          : LightColor.hintTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Muted inline icon inside the composer pill.
class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX12,
          vertical: 12,
        ),
        child: Icon(icon, size: 21, color: LightColor.iconGrey),
      ),
    );
  }
}
