import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, UserProfile>> call(String userId) async {
    return _repository.getProfile(userId);
  }
}
