import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../repositories/profile_repository.dart';

/// Uploads an avatar with the delete-then-upload flow.
///
/// Returns the relative storage path on success (e.g. `avatars/{userId}/avatar.jpg`).
class UploadAvatarUseCase {
  const UploadAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, String>> call(Uint8List bytes, String ext) async {
    return _repository.uploadAvatar(bytes, ext);
  }
}
