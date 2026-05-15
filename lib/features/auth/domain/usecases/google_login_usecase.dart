import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  const GoogleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() async {
    return _repository.signInWithGoogle();
  }
}
