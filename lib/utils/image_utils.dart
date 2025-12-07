import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

/// Utility helpers for image-related operations such as cropping.
class ImageUtils {
  /// Crop an image using [image_cropper] and return a new [XFile].
  ///
  /// If the user cancels cropping, this returns the original image.
  static Future<XFile?> cropImage(
    XFile image, {
    CropAspectRatioPreset? aspectRatio,
  }) async {
    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio:
          aspectRatio != null ? CropAspectRatio(ratioX: 1, ratioY: 1) : null,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit image',
          toolbarColor: const Color(0xFF000000),
          toolbarWidgetColor: const Color(0xFFFFFFFF),
          hideBottomControls: false,
        ),
        IOSUiSettings(title: 'Edit image'),
      ],
    );

    if (cropped == null) return image;
    return XFile(cropped.path);
  }
}
