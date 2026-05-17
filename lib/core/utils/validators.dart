class Validators {
  const Validators._();

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName không được để trống';
    return null;
  }

  static String? fullName(String? value) {
    final req = required(value, 'Họ tên');
    if (req != null) return req;
    if (value!.trim().length < 2) return 'Họ tên phải có ít nhất 2 ký tự';
    if (value.trim().length > 100) return 'Họ tên không được quá 100 ký tự';
    return null;
  }

  static String? email(String? value) {
    final req = required(value, 'Email');
    if (req != null) return req;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    final req = required(value, 'Mật khẩu');
    if (req != null) return req;
    if (value!.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final req = required(value, 'Xác nhận mật khẩu');
    if (req != null) return req;
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  // Profile validators — T-10
  static String? headline(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 120) return 'Tiêu đề không được quá 120 ký tự';
    return null;
  }

  static String? bio(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 500) return 'Giới thiệu không được quá 500 ký tự';
    return null;
  }

  static String? location(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 100) return 'Địa điểm không được quá 100 ký tự';
    return null;
  }
}
