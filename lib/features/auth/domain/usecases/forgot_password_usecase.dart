import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call(String email) async {
    return _repository.resetPassword(email);
  }
}
