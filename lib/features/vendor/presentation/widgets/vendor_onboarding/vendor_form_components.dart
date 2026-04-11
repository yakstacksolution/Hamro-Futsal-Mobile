import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/models/picked_location.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:http/http.dart' as http;

class VendorPanel extends StatelessWidget {
  const VendorPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LightColor.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.borderLight),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.accent.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class VendorPanelHeading extends StatelessWidget {
  const VendorPanelHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: LightColor.titleText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: LightColor.subtitleText,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class VendorSummaryBadge extends StatelessWidget {
  const VendorSummaryBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class VendorErrorBanner extends StatelessWidget {
  const VendorErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: LightColor.redLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightColor.errorBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.error_outline_rounded, color: LightColor.red),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: LightColor.titleText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorFieldLabel extends StatelessWidget {
  const VendorFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: LightColor.titleText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class VendorInputField extends StatelessWidget {
  const VendorInputField({
    super.key,
    this.label,
    this.controller,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.enableIcon,
    this.readOnly = false,
    this.onTap,
    this.isRequired = false,
  });

  final String? label;
  final TextEditingController? controller;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool? enableIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      isRequired: isRequired,
      labelText: label ?? '',
      icon: enableIcon == true
          ? _vendorFieldIcon(label ?? '', keyboardType)
          : null,
      initialValue: initialValue,
      hintText: hintText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: maxLines > 1
          ? TextCapitalization.sentences
          : TextCapitalization.none,
    );
  }
}

class VendorSelectableChip extends StatelessWidget {
  const VendorSelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? LightColor.secondaryLight
              : LightColor.backgroundWarm,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? LightColor.secondary : LightColor.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            VendorMiniCheckbox(isChecked: isSelected),
            const SizedBox(width: 6),
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? LightColor.secondary
                    : LightColor.subtitleText,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? LightColor.secondaryDark
                    : LightColor.titleText,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small custom checkbox widget with animated check
class VendorMiniCheckbox extends StatelessWidget {
  const VendorMiniCheckbox({
    super.key,
    required this.isChecked,
    this.size = 14,
    this.onChanged,
  });

  final bool isChecked;
  final double size;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!isChecked) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked ? LightColor.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isChecked ? LightColor.secondary : LightColor.border,
            width: 1.5,
          ),
        ),
        child: isChecked
            ? Icon(Icons.check_rounded, size: size - 4, color: Colors.white)
            : null,
      ),
    );
  }
}

class VendorUploadSection extends StatelessWidget {
  const VendorUploadSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPick,
    required this.files,
    required this.onRemove,
    this.actionLabel = 'Upload',
    this.actionIcon = Icons.upload_rounded,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPick;
  final List<UploadRef> files;
  final ValueChanged<UploadRef>? onRemove;
  final String actionLabel;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColor.backgroundWarm,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: LightColor.titleText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: LightColor.subtitleText,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              FilledButton.icon(
                onPressed: onPick,
                icon: Icon(actionIcon),
                label: Text(actionLabel),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    LightColor.secondary,
                  ),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (files.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Column(
              children: files
                  .map(
                    (UploadRef file) => VendorUploadItem(
                      file: file,
                      onRemove: onRemove == null ? null : () => onRemove!(file),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class VendorUploadItem extends StatelessWidget {
  const VendorUploadItem({super.key, required this.file, this.onRemove});

  final UploadRef file;
  final VoidCallback? onRemove;

  bool get _isImageFile {
    final String path = _imageSource.toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  String get _imageSource {
    final String remotePath = (file.remoteUrl ?? '').trim();
    return remotePath.isNotEmpty ? remotePath : file.localPath;
  }

  bool get _isNetworkImage {
    final String source = _imageSource.toLowerCase();
    return source.startsWith('http://') || source.startsWith('https://');
  }

  Future<void> _confirmRemove(BuildContext context) async {
    if (onRemove == null) return;

    final bool confirmed = await showConfirmDialog(
      context: context,
      title: 'Remove file?',
      message: 'Do you want to remove "${file.name}" from this selection?',
      confirmText: 'Remove',
      confirmColor: LightColor.secondary,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed) {
      onRemove!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isImageFile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: LightColor.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LightColor.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _isNetworkImage
                  ? CustomImageView(
                      url: _imageSource,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : CustomImageView(
                      file: File(file.localPath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LightColor.titleText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      onPressed: () => _confirmRemove(context),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: LightColor.secondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LightColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightColor.borderLight),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LightColor.secondaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insert_drive_file_rounded,
              color: LightColor.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LightColor.titleText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  file.localPath,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LightColor.subtitleText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: () => _confirmRemove(context),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: LightColor.secondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrokenImageState() {
    return Container(
      color: LightColor.surfaceSubtle,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: LightColor.iconMuted,
        size: 28,
      ),
    );
  }
}

InputDecoration vendorInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: LightColor.backgroundWarm,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: LightColor.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: LightColor.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: LightColor.secondary, width: 1.4),
    ),
  );
}

String stepStatusLabel(StepStatus status) {
  switch (status) {
    case StepStatus.locked:
      return 'Locked';
    case StepStatus.notStarted:
      return 'Not Started';
    case StepStatus.inProgress:
      return 'In Progress';
    case StepStatus.complete:
      return 'Complete';
    case StepStatus.error:
      return 'Needs Attention';
    case StepStatus.pending:
      // TODO: Handle this case.
      throw UnimplementedError();
  }
}

Color stepStatusColor(StepStatus status) {
  switch (status) {
    case StepStatus.locked:
      return LightColor.hintText;
    case StepStatus.notStarted:
      return LightColor.subtitleText;
    case StepStatus.inProgress:
      return LightColor.amber;
    case StepStatus.complete:
      return LightColor.secondary;
    case StepStatus.error:
      return LightColor.red;
    case StepStatus.pending:
      // TODO: Handle this case.
      throw UnimplementedError();
  }
}

String saveStatusLabel(DraftSaveStatus status, DateTime? lastSavedAt) {
  switch (status) {
    case DraftSaveStatus.idle:
      if (lastSavedAt == null) return 'Session state';
      return 'Ready in session';
    case DraftSaveStatus.saving:
      return 'Saving draft...';
    case DraftSaveStatus.saved:
      if (lastSavedAt == null) return 'Draft saved';
      return 'Saved at ${formatTime(lastSavedAt)}';
    case DraftSaveStatus.failure:
      return 'Draft save failed';
    case DraftSaveStatus.error:
      // TODO: Handle this case.
      throw UnimplementedError();
    case DraftSaveStatus.unsaved:
      return 'Session only';
  }
}

String formatTime(DateTime value) {
  final int hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final String minute = value.minute.toString().padLeft(2, '0');
  final String suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

double? parseDouble(String value) {
  final String normalized = value.trim().replaceAll(',', '');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String formatDouble(double? value) {
  if (value == null) return '';
  if (value == value.toInt()) return '${value.toInt()}';
  return value.toString();
}

IconData _vendorFieldIcon(String label, TextInputType? keyboardType) {
  final String normalized = label.toLowerCase();

  if (normalized.contains('exact location')) {
    return Icons.location_on_outlined;
  }

  if (normalized.contains('name')) return Icons.person_outline_rounded;
  if (normalized.contains('registration') || normalized.contains('reg no')) {
    return Icons.confirmation_number_outlined;
  }
  if (normalized.contains('website') || normalized.contains('url')) {
    return Icons.link_rounded;
  }
  if (normalized.contains('social')) return Icons.people_outline_rounded;
  if (normalized.contains('location') ||
      normalized.contains('exact location')) {
    return Icons.image_outlined;
  }
  if (normalized.contains('email')) return Icons.email_outlined;
  if (normalized.contains('phone')) return Icons.phone_outlined;
  if (normalized.contains('address') || normalized.contains('location')) {
    return Icons.location_on_outlined;
  }
  if (normalized.contains('time')) return Icons.schedule_rounded;
  if (normalized.contains('price') ||
      normalized.contains('payment') ||
      normalized.contains('commission')) {
    return Icons.payments_outlined;
  }
  if (normalized.contains('description') ||
      normalized.contains('policy') ||
      normalized.contains('rules')) {
    return Icons.notes_rounded;
  }
  if (keyboardType == TextInputType.phone) return Icons.phone_outlined;
  if (keyboardType == TextInputType.emailAddress) {
    return Icons.email_outlined;
  }
  return Icons.edit_outlined;
}

/// A location search field with autocomplete suggestions from Nominatim.
class VendorLocationSearchField extends StatefulWidget {
  const VendorLocationSearchField({
    super.key,
    required this.initialValue,
    required this.onLocationSelected,
    this.label = 'Exact location',
    this.hintText = 'Search location...',
  });

  final String initialValue;
  final ValueChanged<PickedLocation> onLocationSelected;
  final String label;
  final String hintText;

  @override
  State<VendorLocationSearchField> createState() =>
      _VendorLocationSearchFieldState();
}

class _VendorLocationSearchFieldState extends State<VendorLocationSearchField> {
  late final TextEditingController _controller;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  List<_LocationResult> _results = [];
  bool _isSearching = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(VendorLocationSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final String query = value.trim();
    final int requestId = ++_requestId;

    if (query.length < 3) {
      _removeOverlay();
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _searchPlaces(query, requestId),
    );
  }

  Future<void> _searchPlaces(String query, int requestId) async {
    if (query.isEmpty) return;

    try {
      final Uri uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{
          'q': query,
          'format': 'jsonv2',
          'limit': '6',
          'addressdetails': '1',
        },
      );

      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'User-Agent': 'hamro_footsall/1.0 (location-search)',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode != 200) return;

      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      final List<_LocationResult> matches = decoded
          .map((dynamic item) {
            final Map<String, dynamic> json = item as Map<String, dynamic>;
            return _LocationResult(
              displayName: (json['display_name'] as String? ?? '').trim(),
              latitude: double.parse(json['lat'] as String),
              longitude: double.parse(json['lon'] as String),
            );
          })
          .where((result) => result.displayName.isNotEmpty)
          .toList();

      if (!mounted || requestId != _requestId) return;

      setState(() {
        _results = matches;
        _isSearching = false;
      });

      if (matches.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _isSearching = false);
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.findRenderObject() != null
            ? (context.findRenderObject() as RenderBox?)?.size.width ?? 300
            : 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: LightColor.surface,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LightColor.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: LightColor.secondary,
                    ),
                    title: Text(
                      result.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: LightColor.titleText,
                      ),
                    ),
                    onTap: () => _selectResult(result),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectResult(_LocationResult result) {
    _removeOverlay();
    _controller.text = result.displayName;
    _focusNode.unfocus();

    widget.onLocationSelected(
      PickedLocation(
        label: result.displayName,
        latitude: result.latitude,
        longitude: result.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomTextField(
        controller: _controller,
        focusNode: _focusNode,
        labelText: widget.label,
        hintText: widget.hintText,
        icon: Icons.search_rounded,
        onChanged: _onSearchChanged,
        suffixIcon: _isSearching
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _controller.clear();
                  _removeOverlay();
                  setState(() => _results = []);
                },
              )
            : null,
      ),
    );
  }
}

class _LocationResult {
  const _LocationResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}
