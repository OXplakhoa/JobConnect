import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';

/// Avatar display + picker widget for profile editing.
///
/// Shows current avatar (from URL or local file preview) and opens
/// a bottom sheet to pick from gallery or camera on tap.
///
/// Parent receives the picked image bytes and extension via [onImagePicked].
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    this.currentAvatarPath,
    this.localImage,
    required this.onImagePicked,
  });

  /// Relative path stored in DB (e.g. `avatars/{userId}/avatar.jpg`).
  final String? currentAvatarPath;

  /// Local image bytes for optimistic preview (before upload).
  final Uint8List? localImage;

  /// Callback when user picks an image. Returns bytes + file extension.
  final void Function(Uint8List bytes, String ext) onImagePicked;

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceVariant,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.changeAvatar,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(
                AppStrings.chooseFromGallery,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(
                AppStrings.takePhoto,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image == null) return; // user cancelled

      final bytes = await image.readAsBytes();
      final ext = image.path.split('.').last.toLowerCase();
      final validExt = (ext == 'png') ? 'png' : 'jpg';
      onImagePicked(bytes, validExt);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errorGeneral)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(context),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: _resolveImage(),
                child: _resolveImage() == null
                    ? const Icon(
                        Icons.person,
                        size: 56,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.changeAvatar,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _resolveImage() {
    if (localImage != null) {
      return MemoryImage(localImage!);
    }
    if (currentAvatarPath != null && currentAvatarPath!.isNotEmpty) {
      return NetworkImage(StorageUtils.publicUrl(currentAvatarPath!));
    }
    return null;
  }
}
