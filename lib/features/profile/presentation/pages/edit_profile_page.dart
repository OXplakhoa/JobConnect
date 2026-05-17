import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_picker.dart';

/// Edit profile form (push route at `/profile/edit`).
///
/// ConsumerStatefulWidget with TextEditingControllers.
/// Reads currentProfileProvider ONCE on mount for initial values.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  String? _currentAvatarPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Read ONCE on mount — NOT ref.watch()
    final profileAsync = ref.read(currentProfileProvider);
    final profile = profileAsync.valueOrNull;

    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _headlineController = TextEditingController(text: profile?.headline ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _currentAvatarPath = profile?.avatarUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.editProfile,
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar picker
              AvatarPicker(
                currentAvatarPath: _currentAvatarPath,
                localImage: _pickedImageBytes,
                onImagePicked: (bytes, ext) {
                  setState(() {
                    _pickedImageBytes = bytes;
                    _pickedImageExt = ext;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Full name
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration(AppStrings.fullNameLabel),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: Validators.fullName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Headline
              TextFormField(
                controller: _headlineController,
                decoration: _inputDecoration(AppStrings.headlineLabel),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: Validators.headline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioController,
                decoration: _inputDecoration(AppStrings.bioLabel),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: Validators.bio,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration(AppStrings.locationLabel),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: Validators.location,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.primary.withAlpha(128),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          AppStrings.saveChanges,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.label.copyWith(
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final auth = ref.read(currentProfileProvider).valueOrNull;
      if (auth == null) return;

      String? newAvatarPath;

      // Step 1: Upload avatar if changed
      if (_pickedImageBytes != null && _pickedImageExt != null) {
        final uploadUseCase = UploadAvatarUseCase(profileRepo);
        final uploadResult = await uploadUseCase.call(
          _pickedImageBytes!,
          _pickedImageExt!,
        );
        final failed = uploadResult.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            }
            return true;
          },
          (path) {
            newAvatarPath = path;
            return false;
          },
        );
        if (failed) {
          setState(() => _isSaving = false);
          return;
        }
      }

      // Step 2: Update profile
      final update = ProfileUpdate(
        fullName: _fullNameController.text.trim(),
        headline: _headlineController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        avatarUrl: newAvatarPath,
      );

      final updateUseCase = UpdateProfileUseCase(profileRepo);
      final updateResult = await updateUseCase.call(auth.id, update);

      updateResult.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (_) {
          // Step 3: Invalidate provider to refresh profile data
          ref.invalidate(currentProfileProvider);

          // Step 4: Pop back to ProfilePage
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.profileUpdated)),
            );
            context.pop();
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
