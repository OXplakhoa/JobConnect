import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileDatasource _datasource;

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    return _datasource.getProfile(userId);
  }

  @override
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  ) async {
    return _datasource.updateProfile(userId, update);
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(
    Uint8List bytes,
    String ext,
  ) async {
    return _datasource.uploadAvatar(bytes, ext);
  }
}
