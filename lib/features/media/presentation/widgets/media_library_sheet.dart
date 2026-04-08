import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/features/media/data/model/media_model.dart';
import 'package:hamro_footsall/features/media/data/repositories/media_repository_impl.dart';
import 'package:hamro_footsall/features/media/domain/usecase/media_use_case.dart';
import 'package:hamro_footsall/features/media/presentation/bloc/media_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_state.dart';
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
    builder: (_) => BlocProvider<MediaBloc>(
      lazy: false,
      create: (_) =>
          MediaBloc(MediaUseCase(MediaRepositoryImpl()))
            ..add(const FetchMediaEvent()),
      child: VendorMediaLibrarySheet(
        cubit: cubit,
        title: title,
        subtitle: subtitle,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
        initiallySelected: initiallySelected,
      ),
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
  final Set<String> _knownRemoteKeys = <String>{};
  _LibraryFilter _filter = _LibraryFilter.all;
  bool _isAdding = false;
  List<UploadRef> _pendingUploadFiles = const <UploadRef>[];

  @override
  void initState() {
    super.initState();
    _selectedPaths.addAll(widget.initiallySelected.map(_itemKey));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Set<String> allowed = widget.allowedExtensions
        .map((String item) => item.toLowerCase())
        .toSet();

    return SizedBox(
      height: size.height * 0.8,
      child: BlocListener<MediaBloc, MediaState>(
        listener: _onMediaStateChanged,
        child: BlocBuilder<MediaBloc, MediaState>(
          builder: (BuildContext context, MediaState mediaState) {
            return BlocBuilder<VendorOnboardingCubit, VendorOnboardingState>(
              bloc: widget.cubit,
              builder: (BuildContext context, VendorOnboardingState state) {
                final List<_LibraryItem> library =
                    _buildLibraryItems(
                          localItems: state.mediaLibrary,
                          remoteItems: mediaState.items,
                          allowedExtensions: allowed,
                        )
                        .where((_LibraryItem item) => _matchesFilter(item.file))
                        .toList();
                final bool isFetchingInitialMedia =
                    mediaState.fetchStatus == MediaStatus.loading &&
                    library.isEmpty;

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
                      isAddingImages: _isAdding,
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: mediaState.fetchStatus == MediaStatus.loading
                          ? SizedBox(
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.5,
                                ),
                              ),
                            )
                          : isFetchingInitialMedia
                          ? const _CompactLoadingState()
                          : library.isEmpty
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
                                final _LibraryItem entry = library[index];
                                final bool isSelected = _selectedPaths.contains(
                                  _itemKey(entry.file),
                                );

                                return _CompactMediaCard(
                                  item: entry.file,
                                  isSelected: isSelected,
                                  canRemove: entry.canRemove,
                                  onTap: () => _toggleSelection(entry.file),
                                  onRemove: () => _removeItem(entry.file),
                                );
                              },
                            ),
                    ),

                    SafeArea(
                      top: false,
                      child: _BottomSelectionBar(
                        allowMultiple: widget.allowMultiple,
                        selectionCount: _selectedPaths.length,
                        onConfirm: _selectedPaths.isEmpty
                            ? null
                            : _submitSelection,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onMediaStateChanged(BuildContext context, MediaState state) {
    final List<MediaModel> newlyAddedRemote = _diffNewRemoteItems(state.items);
    _rememberRemoteItems(state.items);

    if (state.fetchStatus == MediaStatus.success && state.items.isNotEmpty) {
      widget.cubit.syncMediaLibrary(
        state.items
            .map(
              (MediaModel item) => UploadRef(
                name: item.name.isNotEmpty
                    ? item.name
                    : item.url.split('/').last,
                localPath: item.url,
                remoteUrl: item.url,
              ),
            )
            .toList(),
      );
    }

    if (state.fetchStatus == MediaStatus.failure &&
        state.errorMessage != null &&
        state.errorMessage!.trim().isNotEmpty) {
      AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
      context.read<MediaBloc>().add(const ClearMediaFeedbackEvent());
      return;
    }

    if (state.createStatus == MediaStatus.failure &&
        state.errorMessage != null &&
        state.errorMessage!.trim().isNotEmpty) {
      AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
      context.read<MediaBloc>().add(const ClearMediaFeedbackEvent());
      setState(() {
        _isAdding = false;
        _pendingUploadFiles = const <UploadRef>[];
      });
      return;
    }

    if (state.createStatus == MediaStatus.success) {
      if (_pendingUploadFiles.isNotEmpty) {
        final List<MediaModel> created = newlyAddedRemote.isNotEmpty
            ? newlyAddedRemote
            : state.items
                  .take(_pendingUploadFiles.length.clamp(0, state.items.length))
                  .toList();
        final List<UploadRef> createdRefs = created
            .map(
              (MediaModel item) => UploadRef(
                name: item.name.isNotEmpty
                    ? item.name
                    : item.url.split('/').last,
                localPath: item.url,
                remoteUrl: item.url,
              ),
            )
            .toList();
        setState(() {
          if (!widget.allowMultiple) {
            _selectedPaths
              ..clear()
              ..add(
                _itemKey(
                  createdRefs.isNotEmpty
                      ? createdRefs.first
                      : _pendingUploadFiles.first,
                ),
              );
          } else {
            _selectedPaths.addAll(
              (createdRefs.isNotEmpty ? createdRefs : _pendingUploadFiles).map(
                _itemKey,
              ),
            );
          }
          _pendingUploadFiles = const <UploadRef>[];
          _isAdding = false;
        });
      }

      if (state.successMessage != null &&
          state.successMessage!.trim().isNotEmpty) {
        AppUtils().showSnackBar(
          context,
          MsgType.success,
          state.successMessage!,
        );
      }
      context.read<MediaBloc>().add(const ClearMediaFeedbackEvent());
    }
  }

  String _remoteKey(MediaModel item) {
    final String id = item.id.trim();
    if (id.isNotEmpty) return 'id:$id';
    final String url = item.url.trim();
    return 'url:$url';
  }

  List<MediaModel> _diffNewRemoteItems(List<MediaModel> items) {
    return items
        .where(
          (MediaModel item) => !_knownRemoteKeys.contains(_remoteKey(item)),
        )
        .toList();
  }

  void _rememberRemoteItems(List<MediaModel> items) {
    for (final MediaModel item in items) {
      _knownRemoteKeys.add(_remoteKey(item));
    }
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
    final String key = _itemKey(item);
    setState(() {
      if (!widget.allowMultiple) {
        _selectedPaths
          ..clear()
          ..add(key);
        return;
      }

      if (!_selectedPaths.add(key)) {
        _selectedPaths.remove(key);
      }
    });
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

    if (files.isEmpty) {
      setState(() => _isAdding = false);
      return;
    }

    final bool confirmed = await _confirmUpload(files);
    if (!mounted) return;

    if (!confirmed) {
      setState(() => _isAdding = false);
      return;
    }

    _pendingUploadFiles = files;
    context.read<MediaBloc>().add(
      CreateMediaEvent(files.map((UploadRef item) => item.localPath).toList()),
    );
  }

  Future<bool> _confirmUpload(List<UploadRef> files) async {
    final bool isSingle = files.length == 1;
    final String fileLabel = isSingle
        ? files.first.name
        : '${files.length} files';
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _UploadMediaPreviewDialog(
          files: files,
          title: 'Upload media?',
          message: isSingle
              ? 'Do you want to upload "$fileLabel" to media library?'
              : 'Do you want to upload $fileLabel to media library?',
        );
      },
    );
    return result ?? false;
  }

  Future<void> _removeItem(UploadRef item) async {
    if ((item.remoteUrl ?? '').trim().isNotEmpty &&
        (item.localPath.trim().isEmpty ||
            item.localPath.trim() == item.remoteUrl!.trim())) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'Remote media is read-only in this library.',
      );
      return;
    }

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
    setState(() => _selectedPaths.remove(_itemKey(item)));
  }

  void _submitSelection() {
    final Set<String> allowed = widget.allowedExtensions
        .map((String item) => item.toLowerCase())
        .toSet();
    final List<UploadRef> allItems = _buildLibraryItems(
      localItems: widget.cubit.state.mediaLibrary,
      remoteItems: context.read<MediaBloc>().state.items,
      allowedExtensions: allowed,
    ).map((_LibraryItem item) => item.file).toList();
    final List<UploadRef> selected = allItems
        .where((UploadRef item) => _selectedPaths.contains(_itemKey(item)))
        .toList();

    Navigator.of(context).pop(selected);
  }

  List<_LibraryItem> _buildLibraryItems({
    required List<UploadRef> localItems,
    required List<MediaModel> remoteItems,
    required Set<String> allowedExtensions,
  }) {
    final Map<String, _LibraryItem> entries = <String, _LibraryItem>{};

    for (final UploadRef item in localItems) {
      if (!_matchesAllowedExtensions(item, allowedExtensions)) continue;
      entries[_itemKey(item)] = _LibraryItem(file: item, canRemove: true);
    }

    for (final MediaModel item in remoteItems) {
      final UploadRef upload = UploadRef(
        name: item.name.isNotEmpty ? item.name : item.url.split('/').last,
        localPath: item.url,
        remoteUrl: item.url,
      );
      if (!_matchesAllowedExtensions(upload, allowedExtensions)) continue;
      entries.putIfAbsent(
        _itemKey(upload),
        () => _LibraryItem(file: upload, canRemove: false),
      );
    }

    return entries.values.toList();
  }
}

class _LibraryItem {
  const _LibraryItem({required this.file, required this.canRemove});

  final UploadRef file;
  final bool canRemove;
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
        color: LightColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LightColor.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: LightColor.secondary,
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
                    color: LightColor.titleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: LightColor.subtitleText,
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
                  color: LightColor.titleText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$selectedCount selected',
                style: const TextStyle(
                  fontSize: 10,
                  color: LightColor.secondary,
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

class _UploadMediaPreviewDialog extends StatelessWidget {
  const _UploadMediaPreviewDialog({
    required this.files,
    required this.title,
    required this.message,
  });

  final List<UploadRef> files;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final UploadRef previewFile = files.first;
    final bool isImage = _isImageFile(previewFile);

    return Dialog(
      backgroundColor: LightColor.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: LightColor.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: LightColor.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LightColor.titleText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LightColor.subtitleText,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: LightColor.backgroundWarm,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LightColor.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: isImage
                  ? AspectRatio(
                      aspectRatio: 1.3,
                      child: CustomImageView(
                        file: File(previewFile.localPath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : _UploadPreviewFallback(file: previewFile),
            ),
            if (files.length > 1) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                '+${files.length - 1} more selected',
                style: const TextStyle(
                  color: LightColor.subtitleText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    isOutlined: true,
                    backgroundColor: Colors.white,
                    foregroundColor: LightColor.subtitleText,
                    borderColor: LightColor.border,
                    minHeight: 44,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Upload',
                    backgroundColor: LightColor.primary,
                    foregroundColor: Colors.white,
                    minHeight: 44,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadPreviewFallback extends StatelessWidget {
  const _UploadPreviewFallback({required this.file});

  final UploadRef file;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(_fileIcon(file), size: 34, color: LightColor.primary),
          const SizedBox(height: 10),
          Text(
            file.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LightColor.titleText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _extensionFor(file).toUpperCase(),
            style: const TextStyle(
              color: LightColor.subtitleText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
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
    required this.isAddingImages,
  });

  final _LibraryFilter activeFilter;
  final ValueChanged<_LibraryFilter> onFilterChanged;
  final VoidCallback? onAddImages;
  final VoidCallback? onAddFiles;
  final bool isAddingImages;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SmallActionButton(
            label: 'Add Image',
            icon: Icons.image_outlined,
            isLoading: isAddingImages,
            onTap: onAddImages,
            accentColor: LightColor.primary,
            softColor: LightColor.primaryLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallActionButton(
            label: 'Add File',
            icon: Icons.insert_drive_file_outlined,
            isLoading: false,
            onTap: onAddFiles,
            accentColor: LightColor.secondary,
            softColor: LightColor.secondaryLight,
          ),
        ),
        const SizedBox(width: 10),
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
      color: LightColor.white,
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
                      ? LightColor.primary
                      : LightColor.subtitleText,
                ),
                const SizedBox(width: 10),
                Text(
                  filter.label,
                  style: TextStyle(
                    color: isActive
                        ? LightColor.primaryDark
                        : LightColor.titleText,
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
          color: LightColor.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LightColor.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: LightColor.primary,
            ),
            const SizedBox(width: 6),
            Text(
              activeFilter.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: LightColor.titleText,
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
    required this.accentColor,
    required this.softColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color accentColor;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Container(
      // color: Colors.amber,
      decoration: BoxDecoration(
        color: LightColor.secondaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDisabled ? LightColor.borderLight : LightColor.border,
        ),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Ink(
          height: 36,
          decoration: BoxDecoration(
            color: LightColor.grey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDisabled ? LightColor.borderLight : LightColor.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: <Widget>[
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDisabled ? LightColor.hintText : accentColor,
                      ),
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 16,
                    color: isDisabled
                        ? LightColor.hintText
                        : LightColor.titleText,
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? LightColor.hintText
                          : LightColor.titleText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactLoadingState extends StatelessWidget {
  const _CompactLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LightColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LightColor.border),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(LightColor.secondary),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Loading media library...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: LightColor.titleText,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Fetching your saved media from the server.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: LightColor.subtitleText),
            ),
          ],
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
          color: LightColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LightColor.border),
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
                color: LightColor.titleText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add images or files to your library.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: LightColor.subtitleText),
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
    required this.canRemove,
    required this.onTap,
    required this.onRemove,
  });

  final UploadRef item;
  final bool isSelected;
  final bool canRemove;
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
            color: LightColor.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? LightColor.primary : LightColor.border,
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: LightColor.primary.withValues(alpha: 0.12),
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
                        child: _MediaPreview(item: item, isImage: isImage),
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
                                    ? LightColor.primary
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
                                    : LightColor.subtitleText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          GestureDetector(
                            onTap: canRemove ? onRemove : null,
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
                                color: LightColor.red,
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
                                color: LightColor.primary.withValues(
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

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.item, required this.isImage});

  final UploadRef item;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    final String? remoteUrl = item.remoteUrl?.trim().isEmpty == true
        ? null
        : item.remoteUrl?.trim();

    if (isImage) {
      if (remoteUrl != null) {
        return CustomImageView(
          url: remoteUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }

      return CustomImageView(
        file: File(item.localPath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return _MiniFilePlaceholder(
      icon: _fileIcon(item),
      label: _extensionFor(item).toUpperCase(),
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
      color: LightColor.backgroundWarm,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 24, color: LightColor.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: LightColor.titleText,
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
        color: LightColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightColor.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: LightColor.titleText,
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
  final String path =
      ((item.remoteUrl ?? '').trim().isNotEmpty
              ? item.remoteUrl!
              : item.localPath)
          .toLowerCase();
  final int index = path.lastIndexOf('.');
  if (index == -1 || index == path.length - 1) return '';
  return path.substring(index + 1);
}

String _itemKey(UploadRef item) {
  final String remoteUrl = item.remoteUrl?.trim() ?? '';
  if (remoteUrl.isNotEmpty) {
    return remoteUrl;
  }
  return item.localPath.trim();
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
