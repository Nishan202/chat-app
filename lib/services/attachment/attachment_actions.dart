import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat_app/utils/file_picker_util.dart';

/// Central place for handling attachment-related actions such as
/// opening camera, gallery, document picker, audio picker, location and contacts.
///
/// Actual implementations can be added later (using packages like
/// `image_picker`, `file_picker`, `geolocator`, `contacts_service`, etc.).
class AttachmentActions {
  const AttachmentActions._();

  /// Open camera and handle captured media.
  static Future<void> handleCamera({
    required BuildContext context,
    Function(List<File>)? onFilesSelected,
  }) async {
    final List<File> files = await FilePickerUtil.pickImageFromCamera(
      context: context,
      enableCrop: true,
    );

    if (files.isNotEmpty) {
      debugPrint('Camera image selected: ${files.first.path}');
      onFilesSelected?.call(files);
    }
  }

  /// Open gallery / photos picker.
  static Future<void> handleGallery({
    required BuildContext context,
    Function(List<File>)? onFilesSelected,
  }) async {
    final List<File> files = await FilePickerUtil.pickImageFromGallery(
      context: context,
      needMultiple: true,
    );

    if (files.isNotEmpty) {
      debugPrint(
        'Gallery files selected: ${files.map((f) => f.path).join(', ')}',
      );
      onFilesSelected?.call(files);
    }
  }

  /// Open document picker (PDF, docs, etc.).
  static Future<void> handleDocument({
    required BuildContext context,
    Function(File)? onFileSelected,
  }) async {
    final File? file = await FilePickerUtil.pickDocument(context: context);

    if (file != null) {
      debugPrint('Document selected: ${file.path}');
      onFileSelected?.call(file);
    }
  }

  /// Open audio picker or start audio selection.
  static Future<void> handleAudio({required BuildContext context}) async {
    // TODO: implement audio functionality
    debugPrint('AttachmentActions.handleAudio called');
  }

  /// Get / share current location.
  static Future<void> handleLocation({required BuildContext context}) async {
    // TODO: implement location functionality
    debugPrint('AttachmentActions.handleLocation called');
  }

  /// Pick contact from address book.
  static Future<void> handleContact({required BuildContext context}) async {
    // TODO: implement contact functionality
    debugPrint('AttachmentActions.handleContact called');
  }
}
