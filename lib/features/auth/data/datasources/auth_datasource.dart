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
}
