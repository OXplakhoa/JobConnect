import '../../../../core/router/user_role.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
  });

  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signInWithGoogle();
  Future<Either<Failure, void>> completeOnboarding(UserRole role);
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> signOut();
}
