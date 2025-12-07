import 'package:flutter/material.dart';

class AttachmentBottomSheet extends StatelessWidget {
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;
  final VoidCallback? onDocumentTap;
  final VoidCallback? onAudioTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onContactTap;

  const AttachmentBottomSheet({
    super.key,
    this.onCameraTap,
    this.onGalleryTap,
    this.onDocumentTap,
    this.onAudioTap,
    this.onLocationTap,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _AttachmentItem(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.pinkAccent,
                  onTap: onCameraTap,
                ),
                _AttachmentItem(
                  icon: Icons.photo,
                  label: 'Gallery',
                  color: Colors.deepPurpleAccent,
                  onTap: onGalleryTap,
                ),
                _AttachmentItem(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.indigo,
                  onTap: onDocumentTap,
                ),
                _AttachmentItem(
                  icon: Icons.audiotrack,
                  label: 'Audio',
                  color: Colors.orange,
                  onTap: onAudioTap,
                ),
                _AttachmentItem(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: Colors.green,
                  onTap: onLocationTap,
                ),
                _AttachmentItem(
                  icon: Icons.person,
                  label: 'Contact',
                  color: Colors.blue,
                  onTap: onContactTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _AttachmentItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
