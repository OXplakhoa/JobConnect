import '../../../../core/errors/failure.dart';
import '../../../../core/router/user_role.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call(UserRole role) async {
    return _repository.completeOnboarding(role);
  }
}
