import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/router/user_role.dart';

part 'register_state.g.dart';

@riverpod
class RegisterIsLoading extends _$RegisterIsLoading {
  @override
  bool build() => false;
  void setLoading(bool loading) => state = loading;
}

@riverpod
class RegisterRole extends _$RegisterRole {
  @override
  UserRole? build() => null;
  void setRole(UserRole role) => state = role;
}
