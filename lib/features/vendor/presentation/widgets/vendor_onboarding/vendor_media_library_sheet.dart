import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';

Future<List<UploadRef>?> showVendorMediaLibrarySheet({
  required BuildContext context,
  required VendorOnboardingCubit cubit,
  required List<String> allowedExtensions,
  required bool allowMultiple,
  String title = 'Media Library',
  String subtitle = 'Select saved media or add new files for this section.',
  List<UploadRef> initiallySelected = const <UploadRef>[],
}) {
  return showAppBottomSheet<List<UploadRef>>(
    context: context,
    builder: (_) => VendorMediaLibrarySheet(
      cubit: cubit,
      title: title,
      subtitle: subtitle,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      initiallySelected: initiallySelected,
    ),
  );
}

class VendorMediaLibrarySheet extends StatefulWidget {
  const VendorMediaLibrarySheet({
    super.key,
    required this.cubit,
    required this.title,
    required this.subtitle,
    required this.allowedExtensions,
    required this.allowMultiple,
    required this.initiallySelected,
  });

  final VendorOnboardingCubit cubit;
  final String title;
  final String subtitle;
  final List<String> allowedExtensions;
  final bool allowMultiple;
  final List<UploadRef> initiallySelected;

  @override
  State<VendorMediaLibrarySheet> createState() =>
      _VendorMediaLibrarySheetState();
}

class _VendorMediaLibrarySheetState extends State<VendorMediaLibrarySheet> {
  final Set<String> _selectedPaths = <String>{};
  _LibraryFilter _filter = _LibraryFilter.all;
  bool _isAdding = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _selectedPaths.addAll(
      widget.initiallySelected.map((UploadRef item) => item.remoteUrl ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Set<String> allowed = widget.allowedExtensions
        .map((String item) => item.toLowerCase())
        .toSet();

    return SizedBox(
      height: size.height * 0.8,
      child: BlocBuilder<VendorOnboardingCubit, VendorOnboardingState>(
        bloc: widget.cubit,
        builder: (BuildContext context, VendorOnboardingState state) {
          final List<UploadRef> library = state.mediaLibrary
              .where(
                (UploadRef item) => _matchesAllowedExtensions(item, allowed),
              )
              .where((UploadRef item) => _matchesFilter(item))
              .toList();

          return Column(
            children: <Widget>[
              _CompactHeader(
                title: widget.title,
                subtitle: widget.subtitle,
                itemCount: library.length,
                selectedCount: _selectedPaths.length,
              ),
              const SizedBox(height: 10),

              _CompactActionRow(
                activeFilter: _filter,
                onFilterChanged: (_LibraryFilter value) {
                  setState(() => _filter = value);
                },
                onAddImages: _visibleImageExtensions(allowed).isEmpty
                    ? null
                    : () => _handleAddFiles(
                        _visibleImageExtensions(allowed).toList(),
                        allowMultiple: true,
                      ),
                onAddFiles: _visibleDocumentExtensions(allowed).isEmpty
                    ? null
                    : () => _handleAddFiles(
                        _visibleDocumentExtensions(allowed).toList(),
                        allowMultiple: true,
                      ),
                onAddFromCamera: _visibleImageExtensions(allowed).isEmpty
                    ? null
                    : _handleCameraCapture,
                isAddingImages: _isAdding,
                isCapturing: _isCapturing,
              ),

              const SizedBox(height: 12),

              Expanded(
                child: library.isEmpty
                    ? _CompactEmptyState(
                        onAddTap: _isAdding
                            ? null
                            : () => _handleAddFiles(
                                allowed.toList(),
                                allowMultiple: true,
                              ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 10),
                        itemCount: library.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final UploadRef item = library[index];
                          final bool isSelected = _selectedPaths.contains(
                            item.remoteUrl ?? '',
                          );

                          return _CompactMediaCard(
                            item: item,
                            isSelected: isSelected,
                            onTap: () => _toggleSelection(item),
                            onRemove: () => _removeItem(item),
                          );
                        },
                      ),
              ),

              SafeArea(
                top: false,
                child: _BottomSelectionBar(
                  allowMultiple: widget.allowMultiple,
                  selectionCount: _selectedPaths.length,
                  onConfirm: _selectedPaths.isEmpty ? null : _submitSelection,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _matchesFilter(UploadRef item) {
    switch (_filter) {
      case _LibraryFilter.all:
        return true;
      case _LibraryFilter.images:
        return _isImageFile(item);
      case _LibraryFilter.files:
        return !_isImageFile(item);
    }
  }

  void _toggleSelection(UploadRef item) {
    setState(() {
      if (!widget.allowMultiple) {
        _selectedPaths
          ..clear()
          ..add(item.remoteUrl ?? '');
        return;
      }

      if (!_selectedPaths.add(item.remoteUrl ?? '')) {
        _selectedPaths.remove(item.remoteUrl ?? '');
      }
    });
  }

  Future<void> _handleCameraCapture() async {
    setState(() => _isCapturing = true);
    final UploadRef? ref = await widget.cubit.pickImageFromCamera();
    if (!mounted) return;
    if (ref != null) {
      setState(() {
        if (!widget.allowMultiple) {
          _selectedPaths
            ..clear()
            ..add(ref.remoteUrl ?? '');
        } else {
          _selectedPaths.add(ref.remoteUrl ?? '');
        }
      });
    }
    setState(() => _isCapturing = false);
  }

  Future<void> _handleAddFiles(
    List<String> extensions, {
    required bool allowMultiple,
  }) async {
    setState(() => _isAdding = true);

    final List<UploadRef> files = await widget.cubit.pickFilesForMediaLibrary(
      allowedExtensions: extensions,
      allowMultiple: allowMultiple,
    );

    if (!mounted) return;

    if (files.isNotEmpty) {
      setState(() {
        if (!widget.allowMultiple) {
          _selectedPaths
            ..clear()
            ..add(files.first.remoteUrl ?? '');
        } else {
          _selectedPaths.addAll(
            files.map((UploadRef item) => item.remoteUrl ?? ''),
          );
        }
      });
    }

    setState(() => _isAdding = false);
  }

  Future<void> _removeItem(UploadRef item) async {
    final bool confirmed = await showConfirmDialog(
      context: context,
      title: 'Remove from media library?',
      message:
          'Do you want to remove "${item.name}" from your saved collection?',
      confirmText: 'Remove',
      icon: Icons.delete_outline_rounded,
    );

    if (!confirmed) return;

    widget.cubit.removeMediaLibraryItem(item);
    setState(() => _selectedPaths.remove(item.remoteUrl ?? ''));
  }

  void _submitSelection() {
    final List<UploadRef> allItems = widget.cubit.state.mediaLibrary;
    final List<UploadRef> selected = allItems
        .where(
          (UploadRef item) => _selectedPaths.contains(item.remoteUrl ?? ''),
        )
        .toList();

    Navigator.of(context).pop(selected);
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.selectedCount,
  });

  final String title;
  final String subtitle;
  final int itemCount;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.borderColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LightColor.secondaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: LightColor.secondaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$itemCount items',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$selectedCount selected',
                style: const TextStyle(
                  fontSize: 10,
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactActionRow extends StatelessWidget {
  const _CompactActionRow({
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onAddImages,
    required this.onAddFiles,
    required this.onAddFromCamera,
    required this.isAddingImages,
    required this.isCapturing,
  });

  final _LibraryFilter activeFilter;
  final ValueChanged<_LibraryFilter> onFilterChanged;
  final VoidCallback? onAddImages;
  final VoidCallback? onAddFiles;
  final VoidCallback? onAddFromCamera;
  final bool isAddingImages;
  final bool isCapturing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SmallActionButton(
            label: 'Gallery',
            icon: Icons.image_outlined,
            isLoading: isAddingImages,
            onTap: onAddImages,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SmallActionButton(
            label: 'Camera',
            icon: Icons.camera_alt_outlined,
            isLoading: isCapturing,
            onTap: onAddFromCamera,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SmallActionButton(
            label: 'File',
            icon: Icons.insert_drive_file_outlined,
            isLoading: false,
            onTap: onAddFiles,
          ),
        ),
        const SizedBox(width: 8),
        _FilterMenuButton(
          activeFilter: activeFilter,
          onSelected: onFilterChanged,
        ),
      ],
    );
  }
}

class _FilterMenuButton extends StatelessWidget {
  const _FilterMenuButton({
    required this.activeFilter,
    required this.onSelected,
  });

  final _LibraryFilter activeFilter;
  final ValueChanged<_LibraryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_LibraryFilter>(
      tooltip: 'Filter library',
      onSelected: onSelected,
      color: LightColor.whiteColor,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (BuildContext context) {
        return _LibraryFilter.values.map((_LibraryFilter filter) {
          final bool isActive = filter == activeFilter;
          return PopupMenuItem<_LibraryFilter>(
            value: filter,
            child: Row(
              children: <Widget>[
                Icon(
                  isActive
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isActive
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                ),
                const SizedBox(width: 10),
                Text(
                  filter.label,
                  style: TextStyle(
                    color: isActive
                        ? LightColor.primaryDark
                        : LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LightColor.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: LightColor.secondaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              activeFilter.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: LightColor.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        height: 36,
        decoration: BoxDecoration(
          color: isDisabled
              ? LightColor.background
              : LightColor.secondaryLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled
                ? LightColor.greyBorderColor
                : LightColor.secondaryLight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: LoadingWidget(isButtonLoading: true),
                )
              else
                Icon(
                  icon,
                  size: 15,
                  color: isDisabled
                      ? LightColor.hintTextColor
                      : LightColor.secondaryColor,
                ),
              const SizedBox(width: 5),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDisabled
                      ? LightColor.hintTextColor
                      : LightColor.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactEmptyState extends StatelessWidget {
  const _CompactEmptyState({required this.onAddTap});

  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LightColor.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: LightColor.secondaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.perm_media_rounded,
                color: LightColor.secondaryDark,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No media found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add images or files to your library.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: CustomButton(
                minHeight: 40,
                text: 'Add Media',
                onPressed: onAddTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactMediaCard extends StatelessWidget {
  const _CompactMediaCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onRemove,
  });

  final UploadRef item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool isImage = _isImageFile(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.borderColor,
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: LightColor.secondaryColor.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: isImage
                            ? CustomImageView(
                                file: File(item.remoteUrl ?? ''),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : _MiniFilePlaceholder(
                                icon: _fileIcon(item),
                                label: _extensionFor(item).toUpperCase(),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: onTap,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? LightColor.secondaryColor
                                    : Colors.white.withValues(alpha: 0.96),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  width: 1.2,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.check_rounded
                                    : Icons.circle_outlined,
                                size: 12,
                                color: isSelected
                                    ? Colors.white
                                    : LightColor.secondaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.96),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  width: 1.2,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 12,
                                color: LightColor.redColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: LightColor.secondaryColor.withValues(
                                  alpha: 0.45,
                                ),
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniFilePlaceholder extends StatelessWidget {
  const _MiniFilePlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LightColor.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 24, color: LightColor.secondaryColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: LightColor.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSelectionBar extends StatelessWidget {
  const _BottomSelectionBar({
    required this.allowMultiple,
    required this.selectionCount,
    required this.onConfirm,
  });

  final bool allowMultiple;
  final int selectionCount;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final String buttonLabel = allowMultiple
        ? 'Use Selected Items'
        : 'Use Selected Item';
    final String titleText = selectionCount == 0
        ? 'No media selected'
        : '$selectionCount item${selectionCount == 1 ? '' : 's'} selected';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightColor.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          const Spacer(),

          SizedBox(
            height: 40,
            width: 160,
            child: CustomButton(
              isLoading: false,
              icon: Icons.arrow_forward_rounded,
              fontSize: 12,
              text: buttonLabel,
              onPressed: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

enum _LibraryFilter {
  all('All'),
  images('Images'),
  files('Files');

  const _LibraryFilter(this.label);

  final String label;
}

bool _matchesAllowedExtensions(UploadRef item, Set<String> allowedExtensions) {
  return allowedExtensions.contains(_extensionFor(item));
}

bool _isImageFile(UploadRef item) {
  const Set<String> imageExtensions = <String>{
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
  };
  return imageExtensions.contains(_extensionFor(item));
}

Set<String> _visibleImageExtensions(Set<String> allowed) {
  return allowed.where((String item) {
    return const <String>{'png', 'jpg', 'jpeg', 'webp', 'gif'}.contains(item);
  }).toSet();
}

Set<String> _visibleDocumentExtensions(Set<String> allowed) {
  return allowed.where((String item) {
    return !_visibleImageExtensions(allowed).contains(item);
  }).toSet();
}

String _extensionFor(UploadRef item) {
  final String path = item.remoteUrl ?? ''.toLowerCase();
  final int index = path.lastIndexOf('.');
  if (index == -1 || index == path.length - 1) return '';
  return path.substring(index + 1);
}

IconData _fileIcon(UploadRef item) {
  switch (_extensionFor(item)) {
    case 'pdf':
      return Icons.picture_as_pdf_rounded;
    case 'doc':
    case 'docx':
      return Icons.description_rounded;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart_rounded;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow_rounded;
    case 'zip':
    case 'rar':
      return Icons.folder_zip_rounded;
    default:
      return Icons.insert_drive_file_rounded;
  }
}
