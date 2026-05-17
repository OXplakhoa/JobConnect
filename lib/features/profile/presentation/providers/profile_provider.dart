import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/domain/entities/user_profile.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    ProfileDatasourceImpl(Supabase.instance.client),
  );
}

/// Watches [authProvider] and auto-rebuilds when auth state changes.
///
/// This is the single source of truth for the current user's profile data.
/// Separate from authProvider which only handles authentication state.
@riverpod
Future<UserProfile> currentProfile(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) throw Exception('Not authenticated');

  final result =
      await ref.watch(profileRepositoryProvider).getProfile(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
}
