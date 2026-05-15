import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String email,
    required String password,
  }) async {
    return _repository.login(email: email, password: password);
  }
}
