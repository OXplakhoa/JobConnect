import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/profile_update.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, void>> call(
    String userId,
    ProfileUpdate update,
  ) async {
    return _repository.updateProfile(userId, update);
  }
}
