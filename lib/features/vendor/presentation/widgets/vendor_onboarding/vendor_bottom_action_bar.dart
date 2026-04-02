import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

class VendorBottomActionBar extends StatelessWidget {
  const VendorBottomActionBar({
    super.key,
    required this.hasPrevious,
    required this.isSubmitting,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final bool hasPrevious;
  final bool isSubmitting;
  final String nextLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !isSubmitting;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  if (hasPrevious) ...<Widget>[
                    _SecondaryActionButton(
                      icon: Icons.arrow_back_ios,
                      label: 'Back',
                      onTap: canInteract ? onPrevious : null,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _PrimaryActionButton(
                      label: nextLabel,
                      onTap: canInteract ? onNext : null,
                      isLoading: isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: isDisabled
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF334155),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDisabled
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF334155),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 48,
        child: CustomButton(
          text: label,
          onPressed: onTap,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
