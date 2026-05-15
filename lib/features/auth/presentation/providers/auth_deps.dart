import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_deps.g.dart';

@riverpod
AuthDatasource authDatasource(Ref ref) {
  return AuthDatasourceImpl(Supabase.instance.client);
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
}

@riverpod
RegisterUseCase registerUseCase(Ref ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}
