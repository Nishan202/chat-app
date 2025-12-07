import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/constant/app_string.dart';
import 'package:chat_app/utils/image_utils.dart';

class FilePickerUtil {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from camera
  static Future<List<File>> pickImageFromCamera({
    required BuildContext context,
    bool enableCrop = false,
    CropAspectRatioPreset? aspectRatio,
  }) async {
    try {
      XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && enableCrop) {
        image = await ImageUtils.cropImage(image, aspectRatio: aspectRatio);
      }
      if (image != null) {
        return [File(image.path)];
      }
      return [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppString.failedToCaptureImage)));
      return [];
    }
  }

  /// Pick image from gallery
  static Future<List<File>> pickImageFromGallery({
    required BuildContext context,
    bool needMultiple = false,
    bool enableCrop = false,
    CropAspectRatioPreset? aspectRatio,
  }) async {
    try {
      if (needMultiple) {
        return await pickMultipleImages(context: context);
      }

      XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null && enableCrop) {
        image = await ImageUtils.cropImage(image, aspectRatio: aspectRatio);
      }

      if (image != null) {
        return [File(image.path)];
      }
      return [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppString.failedToPickImage)));
      return [];
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    required BuildContext context,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        return images.map((image) => File(image.path)).toList();
      }
      return [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppString.failedToPickImages)));
      return [];
    }
  }

  /// Pick document file
  static Future<File?> pickDocument({
    required BuildContext context,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!);
        }
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppString.failedToPickDocument)));
      return null;
    }
  }

  /// Pick multiple document files
  static Future<List<File>> pickMultipleDocuments({
    required BuildContext context,
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppString.failedToPickDocuments)));
      return [];
    }
  }

  /// Pick PDF file specifically
  static Future<File?> pickPdfFile({required BuildContext context}) async {
    return await pickDocument(
      context: context,
      allowedExtensions: const ['pdf'],
    );
  }

  /// Pick image file specifically (jpg, png, jpeg)
  static Future<File?> pickImageFile({required BuildContext context}) async {
    return await pickDocument(
      context: context,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
    );
  }

  /// Validate file size (in MB)
  static bool validateFileSize(
    BuildContext context,
    File file, {
    int maxSizeMB = 5,
  }) {
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (fileSizeInMB > maxSizeMB) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppString.fileTooLargeTitle)));
      return false;
    }
    return true;
  }

  /// Get file size in readable format
  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get file extension
  static String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  static bool isImageFile(File file) {
    final extension = getFileExtension(file);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Check if file is a PDF
  static bool isPdfFile(File file) {
    return getFileExtension(file) == 'pdf';
  }
}
