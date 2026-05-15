import '../../../../core/errors/failure.dart';
import '../../../../core/router/user_role.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
  }) async {
    return _repository.register(
      email: email,
      password: password,
      role: role,
      fullName: fullName,
    );
  }
}
