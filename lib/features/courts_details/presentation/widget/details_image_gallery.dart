import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';

class DetailsImageGallery extends StatefulWidget {
  const DetailsImageGallery({super.key});

  @override
  State<DetailsImageGallery> createState() => _DetailsImageGalleryState();
}

class _DetailsImageGalleryState extends State<DetailsImageGallery> {
  late final PageController _imagePageController;
  int _currentImageIndex = 0;
  bool _isSaved = false;

  final List<String> imageList = [
    'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
    'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
    'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800',
  ];

  @override
  void initState() {
    _imagePageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildImageGallery();
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            itemCount: imageList.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomImageView(
                    url: imageList[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            LightColor.transparentColor,
                            LightColor.primaryTextColor.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Row(
                  children: [
                    _glassButton(icon: Icons.share_outlined, onTap: () {}),
                    const SizedBox(width: 10),
                    _glassButton(
                      icon: _isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _isSaved
                          ? LightColor.secondaryColor
                          : LightColor.whiteColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isSaved = !_isSaved);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(imageList.length, (i) {
                    final active = i == _currentImageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: active ? 24 : 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? LightColor.whiteColor
                            : LightColor.whiteColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LightColor.primaryTextColor.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: LightColor.whiteColor.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo,
                            color: LightColor.whiteColor,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${_currentImageIndex + 1}/${imageList.length}',
                            style: const TextStyle(
                              color: LightColor.whiteColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = LightColor.whiteColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LightColor.primaryTextColor.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: LightColor.whiteColor.withOpacity(0.15)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}
