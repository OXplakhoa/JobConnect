import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/admin_stats.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStats>> getDashboardStats();
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers({
    String? role,
    String? search,
    bool bannedOnly = false,
  });
  Future<Either<Failure, Map<String, dynamic>>> getReportStats();
  Future<Either<Failure, List<Map<String, dynamic>>>> getReports({
    String? status,
  });
  Future<Either<Failure, Map<String, dynamic>?>> getReportById(String id);
  Future<Either<Failure, void>> resolveReport({
    required String reportId,
    required String status,
    String? action,
    String? resolvedBy,
  });
  Future<Either<Failure, void>> banUser({
    required String userId,
    required DateTime bannedUntil,
  });
  Future<Either<Failure, void>> sendWarning(String userId, String message);
  Future<Either<Failure, void>> removeWarning(String userId);
  Future<Either<Failure, void>> closeJobPost(String jobPostId);
  Future<Either<Failure, void>> changeUserRole({
    required String userId,
    required String role,
  });
  Future<Either<Failure, String>> createInviteCode({String role});
  Future<Either<Failure, List<Map<String, dynamic>>>> getInviteCodes();
}
