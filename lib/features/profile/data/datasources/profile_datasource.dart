import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../auth/data/models/profile_model.dart';
import '../../domain/entities/profile_update.dart';

/// Supabase calls for profile operations.
abstract class ProfileDatasource {
  Future<Either<Failure, UserProfile>> getProfile(String userId);
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  );
  Future<Either<Failure, String>> uploadAvatar(Uint8List bytes, String ext);
}

class ProfileDatasourceImpl implements ProfileDatasource {
  const ProfileDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = ProfileModel.fromJson(response).toEntity();
      return Right(profile);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  ) async {
    try {
      await _supabase
          .from('profiles')
          .update(update.toJson())
          .eq('id', userId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(
    Uint8List bytes,
    String ext,
  ) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final storagePath = 'avatars/$userId/avatar.$ext';

      // 1. Delete existing avatar files
      final existingFiles = await _supabase.storage
          .from('public-assets')
          .list(path: 'avatars/$userId');
      if (existingFiles.isNotEmpty) {
        await _supabase.storage.from('public-assets').remove(
              existingFiles
                  .map((f) => 'avatars/$userId/${f.name}')
                  .toList(),
            );
      }

      // 2. Upload new avatar
      await _supabase.storage.from('public-assets').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext'),
          );

      return Right(storagePath);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }
}
