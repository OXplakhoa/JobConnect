import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_datasource.dart';
import '../models/admin_stats_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._datasource);

  final AdminDatasource _datasource;

  @override
  Future<Either<Failure, AdminStats>> getDashboardStats() async {
    try {
      final data = await _datasource.getDashboardStats();
      final model = AdminStatsModel.fromJson(data);
      return Right(model.toEntity());
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers({
    String? role,
    String? search,
    bool bannedOnly = false,
  }) async {
    try {
      final data = await _datasource.getUsers(
        role: role,
        search: search,
        bannedOnly: bannedOnly,
      );
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportStats() async {
    try {
      final data = await _datasource.getReportStats();
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getReports({
    String? status,
  }) async {
    try {
      final data = await _datasource.getReports(status: status);
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getReportById(String id) async {
    try {
      final data = await _datasource.getReportById(id);
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resolveReport({
    required String reportId,
    required String status,
    String? action,
    String? resolvedBy,
  }) async {
    try {
      await _datasource.updateReportStatus(
        reportId: reportId,
        status: status,
        action: action,
        resolvedBy: resolvedBy,
      );
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> banUser({
    required String userId,
    required DateTime bannedUntil,
  }) async {
    try {
      await _datasource.banUser(userId: userId, bannedUntil: bannedUntil);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendWarning(String userId, String message) async {
    try {
      await _datasource.sendWarning(userId, message);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeWarning(String userId) async {
    try {
      await _datasource.removeWarning(userId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> closeJobPost(String jobPostId) async {
    try {
      await _datasource.closeJobPost(jobPostId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changeUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await _datasource.changeUserRole(userId: userId, role: role);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createInviteCode({String role = 'admin'}) async {
    try {
      final code = await _datasource.createInviteCode(role: role);
      return Right(code);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getInviteCodes() async {
    try {
      final data = await _datasource.getInviteCodes();
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
