import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../data/models/profile_model.dart';
import '../../domain/entities/auth_state.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  StreamSubscription<dynamic>? _subscription;

  @override
  AuthState build() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        state = const AuthUnauthenticated();
        return;
      }
      _fetchProfile(session.user.id);
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      _fetchProfile(currentSession.user.id);
      return const AuthInitial();
    } else {
      return const AuthUnauthenticated();
    }
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        state = const AuthError(message: 'Không tìm thấy thông tin hồ sơ');
        return;
      }

      final profile = ProfileModel.fromJson(response).toEntity();
      state = AuthAuthenticated(
        userId: profile.id,
        role: profile.role,
        isOnboardingComplete: profile.isOnboardingComplete,
      );
    } catch (e) {
      state = const AuthError(message: 'Lỗi khi tải thông tin hồ sơ');
    }
  }
}
