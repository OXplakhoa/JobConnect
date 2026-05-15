import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/user_role.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../mappers/auth_error_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
  }) async {
    try {
      await _datasource.register(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthErrorMapper.fromAuthException(e));
    } catch (e, st) {
      return Left(AuthErrorMapper.fromUnknown(e, st));
    }
  }
}
