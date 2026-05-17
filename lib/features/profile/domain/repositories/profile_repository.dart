import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../entities/profile_update.dart';

/// Abstract interface for profile data operations.
abstract class ProfileRepository {
  /// Fetches the profile for the given [userId].
  Future<Either<Failure, UserProfile>> getProfile(String userId);

  /// Updates the profile with the given [update] data.
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  );

  /// Uploads an avatar image and returns the relative storage path.
  ///
  /// Flow: delete existing → upload new → return path.
  Future<Either<Failure, String>> uploadAvatar(Uint8List bytes, String ext);
}
