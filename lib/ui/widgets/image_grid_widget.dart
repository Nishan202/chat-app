import 'dart:io';

import 'package:flutter/material.dart';

/// Widget to display images in a WhatsApp-like grid layout
/// Supports 1-4 images, or 4+ images with a "+N" overlay
class ImageGridWidget extends StatelessWidget {
  final List<String> imageUrls;
  final double maxWidth;
  final double spacing;
  final Function(int index)? onImageTap;

  const ImageGridWidget({
    super.key,
    required this.imageUrls,
    this.maxWidth = 250,
    this.spacing = 2,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageCount = imageUrls.length;
    final displayImages = imageUrls.take(4).toList();
    final remainingCount = imageCount > 4 ? imageCount - 4 : 0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxWidth),
      child: _buildGrid(displayImages, remainingCount),
    );
  }

  Widget _buildGrid(List<String> images, int remainingCount) {
    if (images.length == 1) {
      return _buildSingleImage(images[0], index: 0);
    } else if (images.length == 2) {
      return _buildTwoImages(images);
    } else if (images.length == 3) {
      return _buildThreeImages(images);
    } else {
      return _buildFourOrMoreImages(images, remainingCount);
    }
  }

  Widget _buildSingleImage(String imageUrl, {int index = 0}) {
    return GestureDetector(
      onTap: () => onImageTap?.call(index),
      child: _buildImageItem(
        imageUrl,
        borderRadius: BorderRadius.circular(8),
        width: maxWidth,
        height: maxWidth,
      ),
    );
  }

  Widget _buildTwoImages(List<String> images) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onImageTap?.call(0),
            child: _buildImageItem(
              images[0],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: GestureDetector(
            onTap: () => onImageTap?.call(1),
            child: _buildImageItem(
              images[1],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeImages(List<String> images) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => onImageTap?.call(0),
            child: _buildImageItem(
              images[0],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onImageTap?.call(1),
                  child: _buildImageItem(
                    images[1],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Expanded(
                child: GestureDetector(
                  onTap: () => onImageTap?.call(2),
                  child: _buildImageItem(
                    images[2],
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourOrMoreImages(List<String> images, int remainingCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onImageTap?.call(0),
                  child: _buildImageItem(
                    images[0],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Expanded(
                child: GestureDetector(
                  onTap: () => onImageTap?.call(2),
                  child: _buildImageItem(
                    images[2],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onImageTap?.call(1),
                  child: _buildImageItem(
                    images[1],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Expanded(
                child: GestureDetector(
                  onTap: () => onImageTap?.call(3),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImageItem(
                        images[3],
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      if (remainingCount > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+$remainingCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(
    String imageUrl, {
    required BorderRadius borderRadius,
    double? width,
    double? height,
  }) {
    final isLocalFile =
        imageUrl.startsWith('/') || imageUrl.startsWith('file://');

    return ClipRRect(
      borderRadius: borderRadius,
      child:
          isLocalFile
              ? Image.file(
                File(imageUrl.replaceFirst('file://', '')),
                fit: BoxFit.cover,
                width: width ?? double.infinity,
                height: height ?? double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: width,
                    height: height,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  );
                },
              )
              : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: width ?? double.infinity,
                height: height ?? double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: width,
                    height: height,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: width,
                    height: height,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
