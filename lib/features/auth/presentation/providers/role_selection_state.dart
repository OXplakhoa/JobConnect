import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/router/user_role.dart';

part 'role_selection_state.g.dart';

@riverpod
class RoleSelectionIsLoading extends _$RoleSelectionIsLoading {
  @override
  bool build() => false;
  void setLoading(bool loading) => state = loading;
}

@riverpod
class RoleSelectionRole extends _$RoleSelectionRole {
  @override
  UserRole? build() => null;
  void setRole(UserRole role) => state = role;
}
