import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';

/// Maps Supabase errors to domain Failure types for profile operations.
class ProfileErrorMapper {
  const ProfileErrorMapper._();

  static DatabaseFailure fromPostgrest(PostgrestException e) =>
      DatabaseFailure(message: _toVietnamese(e.message), code: e.code);

  static StorageFailure fromStorage(StorageException e) =>
      StorageFailure(message: e.message);

  static NetworkFailure fromUnknown(Object e, StackTrace st) =>
      NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st);

  static String _toVietnamese(String message) {
    if (message.contains('not found')) return 'Không tìm thấy hồ sơ';
    if (message.contains('permission denied')) {
      return 'Bạn không có quyền thực hiện thao tác này';
    }
    return AppStrings.errorGeneral;
  }
}
