import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/user_role.dart';

abstract class AuthDatasource {
  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
  });

  Future<void> login({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> completeOnboarding(UserRole role);
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class AuthDatasourceImpl implements AuthDatasource {
  const AuthDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role.name,
        'full_name': fullName,
      },
    );
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.jobconnect.job_connect://login-callback',
    );
  }

  @override
  Future<void> completeOnboarding(UserRole role) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('profiles').update({
      'role': role.name,
      'is_onboarding_complete': true,
    }).eq('id', userId);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
