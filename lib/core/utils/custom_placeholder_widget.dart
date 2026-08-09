import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class CustomPlaceHolder extends StatelessWidget {
  final double? height;
  final double? width;
  final String? placeHolder;
  final BoxFit? fit;
  final bool? isHidePlaceholderImage;
  final bool? displayEmptyPic;
  final BorderRadius? radius;

  const CustomPlaceHolder({
    super.key,
    this.height,
    this.width,
    this.placeHolder,
    this.fit,
    this.isHidePlaceholderImage,
    this.displayEmptyPic,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: displayEmptyPic == true
          ? CustomImageView(
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              imagePath: ImageConstants.imagePlaceholderNormal,
              radius: radius,
            )
          : isHidePlaceholderImage == true
          ? SizedBox()
          : SizedBox(
              width: width ?? double.infinity,
              height: height,
              child: loadingWidget(),
            ),
    );
  }

  Widget loadingWidget() {
    return Shimmer.fromColors(
      baseColor: LightColor.skeletonBaseColor,
      highlightColor: LightColor.skeletonHighlightColor,
      child: Container(width: width, height: height, color: LightColor.skeletonBaseColor),
    );
  }
}
