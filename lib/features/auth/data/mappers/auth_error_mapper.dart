import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static AuthFailure fromAuthException(AuthException e) =>
      AuthFailure(message: _toVietnamese(e.message), code: e.statusCode);

  static NetworkFailure fromUnknown(Object e, StackTrace st) =>
      NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st);

  static String _toVietnamese(String message) {
    if (message.contains('already registered')) return 'Email đã được sử dụng';
    if (message.contains('Invalid login credentials')) return 'Email hoặc mật khẩu không đúng';
    if (message.contains('Email not confirmed')) return 'Vui lòng xác nhận email trước khi đăng nhập';
    if (message.contains('Password should be at least')) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (message.contains('security purposes')) return 'Vui lòng chờ trước khi thử lại';
    if (message.contains('User not found')) return 'Email không tồn tại trong hệ thống';
    return AppStrings.errorGeneral;
  }
}
