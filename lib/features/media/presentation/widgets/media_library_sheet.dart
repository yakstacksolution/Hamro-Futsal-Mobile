import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/media/data/model/media_model.dart';
import 'package:hamro_footsall/features/media/data/repositories/media_repository_impl.dart';
import 'package:hamro_footsall/features/media/domain/usecase/media_use_case.dart';
import 'package:hamro_footsall/features/media/presentation/bloc/media_bloc.dart';
import 'package:hamro_footsall/features/media/utils/heic_to_png_jpg.dart';
import 'package:hamro_footsall/features/media/utils/stable_media_file.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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
    wrapWithCustomSheet: false,
    builder: (_) => CustomBottomSheet(
      useSafeArea: false,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX18,
        AppDimens.paddingX12,
        AppDimens.paddingX18,
        0,
      ),
      child: BlocProvider<MediaBloc>(
        lazy: false,
        create: (_) =>
            MediaBloc(MediaUseCase(MediaRepositoryImpl()))
              ..add(const FetchMediaEvent()),
        child: MediaLibrarySheet(
          cubit: cubit,
          title: title,
          subtitle: subtitle,
          allowedExtensions: allowedExtensions,
          allowMultiple: allowMultiple,
          initiallySelected: initiallySelected,
        ),
      ),
    ),
  );
}

class MediaLibrarySheet extends StatefulWidget {
  const MediaLibrarySheet({
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
  State<MediaLibrarySheet> createState() => _VendorMediaLibrarySheetState();
}

class _VendorMediaLibrarySheetState extends State<MediaLibrarySheet> {
  final Set<String> _selectedPaths = <String>{};
  final Set<String> _knownRemoteKeys = <String>{};
  _LibraryFilter _filter = _LibraryFilter.all;
  bool _isAdding = false;
  bool _isCapturing = false;
  List<UploadAttachment> _pendingUploadFiles = const <UploadAttachment>[];

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
      height: size.height * 0.85,
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

                return Stack(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              : () => _handleAddImagesFromGallery(
                                  allowMultiple: widget.allowMultiple,
                                ),
                          onAddFiles:
                              _visibleDocumentExtensions(allowed).isEmpty
                              ? null
                              : () => _handleAddFiles(
                                  _visibleDocumentExtensions(allowed).toList(),
                                  allowMultiple: true,
                                ),
                          onAddFromCamera:
                              _visibleImageExtensions(allowed).isEmpty
                              ? null
                              : _handleAddImageFromCamera,
                          isAddingImages: _isAdding,
                          isCapturing: _isCapturing,
                        ),

                        const SizedBox(height: AppDimens.sizeX12),

                        Expanded(
                          child: mediaState.fetchStatus == MediaStatus.loading
                              ? SizedBox(child: Center(child: LoadingWidget()))
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
                                  padding: const EdgeInsets.only(
                                    bottom: AppDimens.sizeX120,
                                  ),
                                  itemCount: library.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                      ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final _LibraryItem entry =
                                            library[index];
                                        final bool isSelected = _selectedPaths
                                            .contains(_itemKey(entry.file));

                                        return _CompactMediaCard(
                                          item: entry.file,
                                          isSelected: isSelected,
                                          canRemove: entry.canRemove,
                                          onTap: () =>
                                              _toggleSelection(entry.file),
                                          onRemove: () =>
                                              _removeItem(entry.file),
                                        );
                                      },
                                ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        child: _BottomSelectionBar(
                          allowMultiple: widget.allowMultiple,
                          selectionCount: _selectedPaths.length,
                          onConfirm: _selectedPaths.isEmpty
                              ? null
                              : _submitSelection,
                        ),
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
                id: _asInt(item.id),
                name: item.name.isNotEmpty
                    ? item.name
                    : item.url.split('/').last,
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
        _isCapturing = false;
        _pendingUploadFiles = const <UploadAttachment>[];
      });
      return;
    }

    if (state.createStatus == MediaStatus.success) {
      if (_pendingUploadFiles.isNotEmpty) {
        final List<UploadRef> createdRefs = newlyAddedRemote
            .where((MediaModel item) => item.url.trim().isNotEmpty)
            .map(
              (MediaModel item) => UploadRef(
                id: _asInt(item.id),
                name: item.name.isNotEmpty
                    ? item.name
                    : item.url.split('/').last,
                remoteUrl: item.url,
              ),
            )
            .toList();
        if (createdRefs.isEmpty) {
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            'The upload completed without a usable media reference. Please try again.',
          );
        }
        setState(() {
          if (!widget.allowMultiple && createdRefs.isNotEmpty) {
            _selectedPaths
              ..clear()
              ..add(_itemKey(createdRefs.first));
          } else {
            _selectedPaths.addAll(createdRefs.map(_itemKey));
          }
          _pendingUploadFiles = const <UploadAttachment>[];
          _isAdding = false;
          _isCapturing = false;
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

    try {
      final List<UploadRef> files = await widget.cubit.pickFilesForMediaLibrary(
        allowedExtensions: extensions,
        allowMultiple: allowMultiple,
      );
      if (!mounted) return;
      if (files.length > kUploadMaxFilesPerRequest) {
        throw const UploadValidationException(
          UploadValidationCode.tooManyFiles,
          'You can upload at most 5 files at once.',
        );
      }
      final UploadPolicy policy = UploadPolicy(
        allowedExtensions: extensions.toSet(),
      );
      final List<UploadAttachment> attachments = <UploadAttachment>[];
      for (final UploadRef file in files) {
        final String path = file.remoteUrl?.trim() ?? '';
        attachments.add(
          await loadUploadAttachment(
            path: path,
            filename: file.name,
            policy: policy,
          ),
        );
      }
      if (!mounted) return;
      await _confirmAndUpload(attachments);
    } on UploadValidationException catch (error) {
      if (!mounted) return;
      AppUtils().showSnackBar(context, MsgType.error, error.message);
      setState(() => _isAdding = false);
    }
  }

  Future<void> _handleAddImagesFromGallery({
    required bool allowMultiple,
  }) async {
    setState(() => _isAdding = true);

    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedImages = allowMultiple
          ? await picker.pickMultiImage(
              maxWidth: 1920,
              maxHeight: 1920,
              imageQuality: 85,
            )
          : <XFile>[
              if (await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1920,
                    imageQuality: 85,
                  )
                  case final XFile image)
                image,
            ];

      if (!mounted) return;

      final List<XFile> stableImages = <XFile>[];
      for (final XFile image in pickedImages) {
        final XFile? stableImage = await stabilizePickedMedia(image);
        if (stableImage != null) {
          stableImages.add(stableImage);
        }
      }
      if (!mounted) return;

      if (stableImages.length != pickedImages.length) {
        AppUtils().showSnackBar(
          context,
          MsgType.error,
          'The selected image is empty. Please select the original image again.',
        );
        setState(() => _isAdding = false);
        return;
      }

      if (stableImages.length > kUploadMaxFilesPerRequest) {
        throw const UploadValidationException(
          UploadValidationCode.tooManyFiles,
          'You can upload at most 5 files at once.',
        );
      }
      final UploadPolicy policy = UploadPolicy(
        allowedExtensions: widget.allowedExtensions.toSet(),
      );
      final List<UploadAttachment> attachments = <UploadAttachment>[];
      for (final XFile image in stableImages) {
        attachments.add(await _loadImageAttachment(image, policy));
      }
      if (!mounted) return;
      await _confirmAndUpload(attachments);
    } on UploadValidationException catch (error) {
      if (!mounted) return;
      AppUtils().showSnackBar(context, MsgType.error, error.message);
      setState(() => _isAdding = false);
    } catch (error) {
      if (!mounted) return;
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Could not select image. Please try again.',
      );
      setState(() => _isAdding = false);
    }
  }

  Future<void> _handleAddImageFromCamera() async {
    setState(() => _isCapturing = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? captured = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      final XFile? photo = captured == null
          ? null
          : await stabilizePickedMedia(captured);

      if (!mounted) return;

      if (captured != null && photo == null) {
        AppUtils().showSnackBar(
          context,
          MsgType.error,
          'The camera did not finish saving the image. Please take the photo again.',
        );
        setState(() => _isCapturing = false);
        return;
      }

      final List<UploadAttachment> attachments = photo == null
          ? const <UploadAttachment>[]
          : <UploadAttachment>[
              await _loadImageAttachment(
                photo,
                UploadPolicy(
                  allowedExtensions: widget.allowedExtensions.toSet(),
                ),
              ),
            ];
      if (!mounted) return;
      await _confirmAndUpload(attachments, isCamera: true);
    } on UploadValidationException catch (error) {
      if (!mounted) return;
      AppUtils().showSnackBar(context, MsgType.error, error.message);
      setState(() => _isCapturing = false);
    } catch (error) {
      if (!mounted) return;
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Could not open camera. Please try again.',
      );
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _confirmAndUpload(
    List<UploadAttachment> files, {
    bool isCamera = false,
  }) async {
    if (!mounted) return;

    if (files.isEmpty) {
      setState(() {
        _isAdding = false;
        if (isCamera) _isCapturing = false;
      });
      return;
    }

    try {
      validateUploadBatch(files);
    } on UploadValidationException catch (error) {
      AppUtils().showSnackBar(context, MsgType.error, error.message);
      setState(() {
        _isAdding = false;
        if (isCamera) _isCapturing = false;
      });
      return;
    }

    final bool confirmed = await _confirmUpload(
      files.map(_previewRefForAttachment).toList(growable: false),
    );
    if (!mounted) return;

    if (!confirmed) {
      setState(() {
        _isAdding = false;
        if (isCamera) _isCapturing = false;
      });
      return;
    }

    setState(() {
      _pendingUploadFiles = files;
    });
    context.read<MediaBloc>().add(CreateMediaEvent(files));
  }

  UploadRef _previewRefForAttachment(UploadAttachment attachment) =>
      UploadRef(name: attachment.filename, remoteUrl: attachment.sourcePath);

  Future<UploadAttachment> _loadImageAttachment(
    XFile image,
    UploadPolicy policy,
  ) async {
    final String convertedPath = await heicToPngJpg(image.path);
    final String convertedName = convertedPath == image.path
        ? image.name
        : convertedPath.split(Platform.pathSeparator).last;
    return loadUploadAttachment(
      path: convertedPath,
      filename: convertedName,
      policy: policy,
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
          title: StringConstants.uploadMedia,
          message: isSingle
              ? 'Do you want to upload "$fileLabel" to media library?'
              : 'Do you want to upload $fileLabel to media library?',
        );
      },
    );
    return result ?? false;
  }

  Future<void> _removeItem(UploadRef item) async {
    if (_isRemoteUrl(item.remoteUrl)) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'Remote media is read-only in this library.',
      );
      return;
    }

    final bool confirmed = await showConfirmDialog(
      context: context,
      title: StringConstants.removeFromMediaLibrary,
      message:
          'Do you want to remove "${item.name}" from your saved collection?',
      confirmText: StringConstants.remove,
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
        id: _asInt(item.id),
        name: item.name.isNotEmpty ? item.name : item.url.split('/').last,
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
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX46,
            height: AppDimens.sizeX46,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Icon(
              Icons.photo_outlined,
              color: LightColor.inverseTextColor,
              size: AppDimens.sizeX22,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColor.primaryTextColor,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodySubTitle
                      ?.copyWith(color: LightColor.secondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$itemCount items',
                style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                '$selectedCount selected',
                style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: LightColor.secondaryColor,
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
      backgroundColor: LightColor.whiteColor,
      insetPadding: AppUtils().getPadding(horizontal: AppDimens.paddingX20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX52,
              height: AppDimens.sizeX52,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX16),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: LightColor.inverseTextColor,
                size: AppDimens.sizeX26,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX14),
            Text(
              title,
              textAlign: TextAlign.center,

              style: FutsalTheme.getTextTheme(context).headingSubTitle
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
            ),
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: LightColor.background,
                borderRadius: BorderRadius.circular(AppDimens.radiusX16),
                border: Border.all(color: LightColor.borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: isImage
                  ? AspectRatio(
                      aspectRatio: 1.3,
                      child: _MediaPreview(item: previewFile, isImage: true),
                    )
                  : _UploadPreviewFallback(file: previewFile),
            ),
            if (files.length > 1) ...<Widget>[
              const SizedBox(height: AppDimens.sizeX10),
              Text(
                '+${files.length - 1} more selected',
                style: TextStyle(
                  color: LightColor.secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppDimens.sizeX18),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: StringConstants.cancel,
                    isOutlined: true,
                    backgroundColor: LightColor.onBrandSurface,
                    foregroundColor: LightColor.secondaryTextColor,
                    borderColor: LightColor.borderColor,
                    minHeight: AppDimens.sizeX44,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: CustomButton(
                    text: StringConstants.upload,
                    backgroundColor: LightColor.secondaryColor,
                    foregroundColor: LightColor.onBrandSurface,
                    minHeight: AppDimens.sizeX44,
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
      padding: AppUtils().getPadding(all: AppDimens.sizeX18),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            _fileIcon(file),
            size: AppDimens.sizeX34,
            color: LightColor.secondaryColor,
          ),
          const SizedBox(height: AppDimens.sizeX10),
          Text(
            file.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,

            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX4),
          Text(
            _extensionFor(file).toUpperCase(),

            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.secondaryTextColor,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: _AddMediaMenuButton(
            onAddImages: onAddImages,
            onAddFromCamera: onAddFromCamera,
            onAddFiles: onAddFiles,
            isLoading: isAddingImages || isCapturing,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX8),
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
      tooltip: StringConstants.filterLibrary,
      onSelected: onSelected,
      color: LightColor.whiteColor,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
      ),
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
                  size: AppDimens.sizeX18,
                  color: isActive
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                ),
                const SizedBox(width: AppDimens.sizeX10),
                Text(
                  filter.label,
                  style: TextStyle(
                    color: isActive
                        ? LightColor.brandTextColor
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
        height: AppDimens.sizeX42,
        padding: AppUtils().getPadding(horizontal: AppDimens.paddingX10),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          border: Border.all(color: LightColor.greyBorderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.filter_list_rounded,
              size: AppDimens.sizeX18,
              color: LightColor.secondaryColor,
            ),
            const SizedBox(width: AppDimens.sizeX6),
            Text(
              activeFilter.label,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
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

enum _AddSource {
  gallery('Gallery', 'Choose from your photos', Icons.image_outlined),
  camera('Camera', 'Take a new photo', Icons.photo_camera_outlined),
  files('Files', 'Browse documents', Icons.insert_drive_file_outlined);

  const _AddSource(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;
}

class _AddMediaMenuButton extends StatelessWidget {
  const _AddMediaMenuButton({
    required this.onAddImages,
    required this.onAddFromCamera,
    required this.onAddFiles,
    required this.isLoading,
  });

  final VoidCallback? onAddImages;
  final VoidCallback? onAddFromCamera;
  final VoidCallback? onAddFiles;
  final bool isLoading;

  VoidCallback? _callbackFor(_AddSource source) {
    switch (source) {
      case _AddSource.gallery:
        return onAddImages;
      case _AddSource.camera:
        return onAddFromCamera;
      case _AddSource.files:
        return onAddFiles;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAnyOption =
        onAddImages != null || onAddFromCamera != null || onAddFiles != null;
    final bool isDisabled = !hasAnyOption || isLoading;

    return PopupMenuButton<_AddSource>(
      enabled: !isDisabled,
      tooltip: StringConstants.pickFrom,
      offset: const Offset(0, AppDimens.sizeX8),
      color: LightColor.whiteColor,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
      ),
      onSelected: (_AddSource source) {
        final VoidCallback? callback = _callbackFor(source);
        if (callback == null) return;

        WidgetsBinding.instance.addPostFrameCallback((_) => callback());
      },
      itemBuilder: (BuildContext context) {
        return _AddSource.values.map((_AddSource source) {
          final bool enabled = _callbackFor(source) != null;
          return PopupMenuItem<_AddSource>(
            value: source,
            enabled: enabled,
            child: Row(
              children: <Widget>[
                Container(
                  width: AppDimens.sizeX36,
                  height: AppDimens.sizeX36,
                  decoration: BoxDecoration(
                    color: LightColor.dividerColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                  ),
                  child: Icon(
                    source.icon,
                    size: AppDimens.sizeX18,
                    color: enabled
                        ? LightColor.secondaryColor
                        : LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      source.label,
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: enabled
                                ? LightColor.primaryTextColor
                                : LightColor.secondaryTextColor,
                          ),
                    ),
                    Text(
                      source.description,
                      style: FutsalTheme.getTextTheme(context).bodySubTitle
                          ?.copyWith(color: LightColor.secondaryTextColor),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList();
      },
      child: CustomPaint(
        foregroundPainter: _DashedRRectPainter(
          color: LightColor.greyBorderColor,
          radius: AppDimens.radiusX10,
        ),
        child: Container(
          height: AppDimens.sizeX42,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          padding: AppUtils().getPadding(horizontal: AppDimens.paddingX12),
          child: Row(
            children: <Widget>[
              if (isLoading)
                const SizedBox(
                  width: AppDimens.sizeX18,
                  height: AppDimens.sizeX18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LightColor.secondaryColor,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: AppDimens.sizeX18,
                  color: isDisabled
                      ? LightColor.secondaryTextColor
                      : LightColor.secondaryColor,
                ),
              const SizedBox(width: AppDimens.sizeX8),
              Flexible(
                child: Text(
                  StringConstants.pickFrom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDisabled
                            ? LightColor.secondaryTextColor
                            : LightColor.secondaryColor,
                      ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: AppDimens.sizeX18,
                color: isDisabled
                    ? LightColor.secondaryTextColor
                    : LightColor.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, this.radius = 10});

  final Color color;
  final double radius;

  static const double _strokeWidth = 1.4;
  static const double _dashLength = 5;
  static const double _gapLength = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + _dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _CompactLoadingState extends StatelessWidget {
  const _CompactLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: AppUtils().getPadding(all: AppDimens.paddingX20),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(color: LightColor.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 28, height: 28, child: LoadingWidget()),
            SizedBox(height: 12),
            Text(
              StringConstants.loadingMediaLibrary,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
              ),
            ),
            SizedBox(height: 6),
            Text(
              StringConstants.fetchingYourSavedMediaFromTheServer,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: LightColor.secondaryTextColor,
              ),
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
        padding: AppUtils().getPadding(all: AppDimens.paddingX20),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(color: LightColor.greyBorderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX58,
              height: AppDimens.sizeX58,
              decoration: BoxDecoration(
                color: LightColor.greyBorderColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              ),
              child: Icon(
                Icons.perm_media_rounded,
                color: LightColor.brandTextColor,
                size: AppDimens.sizeX28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              StringConstants.noMediaFound,

              style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX6),
            Text(
              StringConstants.addImagesOrFilesToYourLibrary,
              textAlign: TextAlign.center,

              style: FutsalTheme.getTextTheme(
                context,
              ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
            ),
            const SizedBox(height: AppDimens.sizeX16),

            Padding(
              padding: AppUtils().getPadding(horizontal: AppDimens.paddingX20),
              child: CustomButton(
                minHeight: AppDimens.sizeX40,
                text: StringConstants.addMedia,
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
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(4),
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
                        child: _MediaPreview(item: item, isImage: isImage),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: AppDimens.sizeX40,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                LightColor.shadowOf(0.28),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppDimens.sizeX6,
                      right: AppDimens.sizeX6,
                      child: GestureDetector(
                        onTap: onTap,
                        child: Container(
                          width: AppDimens.sizeX20,
                          height: AppDimens.sizeX20,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? LightColor.secondaryColor
                                : LightColor.onBrandSurface.withValues(
                                    alpha: 0.96,
                                  ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected
                                  ? LightColor.onBrandSurface
                                  : LightColor.borderColor,
                              width: 1.4,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: LightColor.shadowOf(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            size: AppDimens.sizeX14,
                            color: isSelected
                                ? LightColor.onBrandSurface
                                : LightColor.secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                    // if (canRemove)
                    //   Positioned(
                    //     top: AppDimens.sizeX6,
                    //     left: AppDimens.sizeX6,
                    //     child: GestureDetector(
                    //       onTap: onRemove,
                    //       child: Container(
                    //         width: AppDimens.sizeX24,
                    //         height: AppDimens.sizeX24,
                    //         decoration: BoxDecoration(
                    //           color: LightColor.redColor,
                    //           borderRadius: BorderRadius.circular(999),
                    //           border: Border.all(
                    //             color: LightColor.onBrandSurface,
                    //             width: 1.4,
                    //           ),
                    //           boxShadow: <BoxShadow>[
                    //             BoxShadow(
                    //               color: LightColor.redColor.withValues(
                    //                 alpha: 0.35,
                    //               ),
                    //               blurRadius: 6,
                    //               offset: const Offset(0, 2),
                    //             ),
                    //           ],
                    //         ),
                    //         child: const Icon(
                    //           Icons.delete_outline_rounded,
                    //           size: AppDimens.sizeX14,
                    //           color: LightColor.onBrandSurface,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
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
      if (_isRemoteUrl(remoteUrl)) {
        return CustomImageView(
          url: remoteUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }

      if (_isLocalPath(remoteUrl)) {
        return CustomImageView(
          file: File(remoteUrl!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }

      return const _MiniFilePlaceholder(
        icon: Icons.broken_image_outlined,
        label: StringConstants.image,
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
      color: LightColor.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 24, color: LightColor.secondaryColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
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
      padding: AppUtils().getPadding(all: AppDimens.paddingX10),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            titleText,

            style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),

          const Spacer(),
          SizedBox(
            height: AppDimens.sizeX40,
            width: AppDimens.sizeX200,
            child: CustomButton(
              isLoading: false,
              icon: Icons.arrow_forward_rounded,
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
  final String rawPath = (item.remoteUrl ?? item.name).trim();
  final String path = rawPath.split('?').first.toLowerCase();
  final int index = path.lastIndexOf('.');
  if (index == -1 || index == path.length - 1) return '';
  return path.substring(index + 1);
}

String _itemKey(UploadRef item) {
  if (item.id != null) return 'id:${item.id}';
  final String remoteUrl = item.remoteUrl?.trim() ?? '';
  if (remoteUrl.isNotEmpty) {
    return _isRemoteUrl(remoteUrl) ? 'remote:$remoteUrl' : 'local:$remoteUrl';
  }
  return 'name:${item.name}';
}

bool _isRemoteUrl(String? value) {
  if (value == null) return false;
  final String path = value.trim().toLowerCase();
  return path.startsWith('http://') || path.startsWith('https://');
}

bool _isLocalPath(String? value) {
  if (value == null) return false;
  final String path = value.trim();
  if (path.isEmpty || _isRemoteUrl(path)) return false;
  return File(path).existsSync();
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

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
