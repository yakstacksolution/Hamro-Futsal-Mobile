import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';

class VendorBottomActionBar extends StatelessWidget {
  const VendorBottomActionBar({
    super.key,
    required this.hasPrevious,
    required this.isSubmitting,
    required this.nextLabel,
    required this.saveStatus,
    required this.lastSavedAt,
    required this.onPrevious,
    required this.onSave,
    required this.onNext,
  });

  final bool hasPrevious;
  final bool isSubmitting;
  final String nextLabel;
  final DraftSaveStatus saveStatus;
  final DateTime? lastSavedAt;
  final VoidCallback onPrevious;
  final VoidCallback onSave;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !isSubmitting;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
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
                  _IconOnlyAction(
                    icon: Icons.bookmark_border_rounded,
                    onTap: canInteract ? onSave : null,
                    isLoading: false,
                  ),
                  const SizedBox(width: 12),
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
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
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
              const SizedBox(width: 6),
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

class _IconOnlyAction extends StatelessWidget {
  const _IconOnlyAction({
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: isDisabled
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF334155),
                  ),
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
