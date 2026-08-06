import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hamro_footsall/core/utils/custom_placeholder_widget.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

// Custom Cache Manager Configuration
final customCacheManager = CacheManager(
  Config(
    'customImageCache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
    fileService: HttpFileService(),
    repo: JsonCacheInfoRepository(databaseName: "CustomImageCache"),
  ),
);

class CustomImageView extends StatelessWidget {
  final String? url;
  final String? imagePath;
  final String? svgPath;
  final File? file;
  final Uint8List? imageBytes;
  final double? height;
  final double? width;
  final double? cacheHeight;
  final double? cacheWidth;
  final Color? color;
  final BoxFit? fit;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;
  final String placeHolder;
  final bool svgFromOnline;
  final bool isHidePlaceholderImage;

  const CustomImageView({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.imageBytes,
    this.height,
    this.width,
    this.cacheHeight,
    this.cacheWidth,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder = "assets/images/placeholder_pic.png",
    this.svgFromOnline = false,
    this.isHidePlaceholderImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildAlignedWidget(context);
  }

  int? _toCacheDimension(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null) return null;
    if (!logicalSize.isFinite || logicalSize <= 0) return null;
    final physicalSize = logicalSize * devicePixelRatio;
    if (!physicalSize.isFinite || physicalSize <= 0) return null;
    return physicalSize.round();
  }

  String? _normalizeNetworkUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return Uri.encodeFull(trimmed);
  }

  bool _isSvgPath(String? value) {
    if (value == null) return false;
    return value.trim().toLowerCase().endsWith('.svg');
  }

  Widget _buildAlignedWidget(BuildContext context) {
    final imageWidget = _buildImageWidget(context);
    return alignment != null
        ? Align(alignment: alignment!, child: imageWidget)
        : imageWidget;
  }

  Widget _buildImageWidget(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(onTap: onTap, child: _buildStyledImage(context)),
    );
  }

  Widget _buildStyledImage(BuildContext context) {
    final imageContent = _buildImageContent(context);
    if (radius == null && border == null) return imageContent;

    return Container(
      decoration: BoxDecoration(border: border, borderRadius: radius),
      child: ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: imageContent,
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final String? normalizedUrl = _normalizeNetworkUrl(url);
    final String? normalizedImagePath = _normalizeNetworkUrl(imagePath);

    if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: svgFromOnline
            ? FutureBuilder<Uint8List>(
                future: getSvgBytes(svgPath!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SvgPicture.memory(
                      snapshot.data!,
                      height: height,
                      width: width,
                      fit: fit ?? BoxFit.contain,
                      colorFilter: color != null
                          ? ColorFilter.mode(color!, BlendMode.srcIn)
                          : null,
                    );
                  } else {
                    return _buildPlaceholder(context);
                  }
                },
              )
            : SvgPicture.asset(
                svgPath!,
                height: height,
                width: width,
                fit: fit ?? BoxFit.contain,
                colorFilter: color != null
                    ? ColorFilter.mode(color!, BlendMode.srcIn)
                    : null,
                placeholderBuilder: (BuildContext context) =>
                    _buildPlaceholder(context),
              ),
      );
    }

    if (file != null && file!.path.isNotEmpty) {
      return Image.file(
        file!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        cacheHeight: _toCacheDimension(height, devicePixelRatio),
        cacheWidth: _toCacheDimension(width, devicePixelRatio),
      );
    }

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        cacheHeight: _toCacheDimension(height, devicePixelRatio),
        cacheWidth: _toCacheDimension(width, devicePixelRatio),
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    final String? networkCandidate =
        normalizedUrl ??
        (normalizedImagePath != null &&
                (normalizedImagePath.startsWith('http://') ||
                    normalizedImagePath.startsWith('https://'))
            ? normalizedImagePath
            : null);

    if (networkCandidate != null) {
      if (networkCandidate.toLowerCase().endsWith('.svg')) {
        return SizedBox(
          height: height,
          width: width,
          child: FutureBuilder<Uint8List>(
            future: getSvgBytes(networkCandidate),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SvgPicture.memory(
                  snapshot.data!,
                  height: height,
                  width: width,
                  fit: fit ?? BoxFit.contain,
                  colorFilter: color != null
                      ? ColorFilter.mode(color!, BlendMode.srcIn)
                      : null,
                );
              }
              return _buildPlaceholder(context);
            },
          ),
        );
      }

      return SizedBox(
        height: height,
        width: width,
        child: CachedNetworkImage(
          imageUrl: networkCandidate,
          fit: fit ?? BoxFit.cover,
          color: color,
          cacheManager: customCacheManager,
          fadeInDuration: const Duration(milliseconds: 150),
          fadeOutDuration: const Duration(milliseconds: 100),
          // The displayed widget can intentionally use infinity to fill its
          // parent. Callers that know the finite layout bounds can still keep
          // the decoded bitmap close to its on-screen size via these hints.
          // This avoids decoding multi-megapixel venue photos while scrolling.
          memCacheHeight: _toCacheDimension(
            cacheHeight ?? height,
            devicePixelRatio,
          ),
          memCacheWidth: _toCacheDimension(
            cacheWidth ?? width,
            devicePixelRatio,
          ),
          placeholder: (_, __) => _buildPlaceholder(context),
          errorWidget: (_, error, __) {
            return _buildPlaceholder(context);
          },
        ),
      );
    }

    if (imagePath != null && imagePath!.trim().isNotEmpty) {
      if (_isSvgPath(imagePath)) {
        return SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            imagePath!.trim(),
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
            placeholderBuilder: (BuildContext context) =>
                _buildPlaceholder(context),
          ),
        );
      }

      return Image.asset(
        imagePath!.trim(),
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlaceholder(BuildContext context) {
    return CustomPlaceHolder(
      isHidePlaceholderImage: isHidePlaceholderImage,
      height: height ?? AppDimens.sizeX30,
      width: width ?? AppDimens.sizeX30,
      fit: fit ?? BoxFit.cover,
    );
  }

  Future<Uint8List> getSvgBytes(String url) async {
    final fileInfo = await customCacheManager.getSingleFile(url);
    return fileInfo.readAsBytes();
  }
}
