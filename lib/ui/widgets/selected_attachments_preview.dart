import 'dart:io';

import 'package:chat_app/utils/file_picker_util.dart';
import 'package:flutter/material.dart';

/// Model to represent a selected attachment
class SelectedAttachment {
  final File file;
  final String id; // Unique identifier for the attachment

  SelectedAttachment({required this.file, required this.id});
}

/// Widget to display selected attachments in a horizontal scrollable list
/// Similar to WhatsApp's attachment preview
/// Uses ValueNotifier to avoid rebuilding the entire parent widget
class SelectedAttachmentsPreview extends StatefulWidget {
  final ValueNotifier<List<SelectedAttachment>> attachmentsNotifier;
  final Function(String id) onRemove;

  const SelectedAttachmentsPreview({
    super.key,
    required this.attachmentsNotifier,
    required this.onRemove,
  });

  @override
  State<SelectedAttachmentsPreview> createState() =>
      _SelectedAttachmentsPreviewState();
}

class _SelectedAttachmentsPreviewState
    extends State<SelectedAttachmentsPreview> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SelectedAttachment>>(
      valueListenable: widget.attachmentsNotifier,
      builder: (context, attachments, child) {
        if (attachments.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              final isImage = FilePickerUtil.isImageFile(attachment.file);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            isImage
                                ? Image.file(
                                  attachment.file,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file,
                                        size: 32,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        FilePickerUtil.getFileExtension(
                                          attachment.file,
                                        ).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                    // Cancel button (cross icon)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: GestureDetector(
                        onTap: () => widget.onRemove(attachment.id),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
