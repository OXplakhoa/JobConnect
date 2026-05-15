import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_state.g.dart';

@riverpod
class LoginIsLoading extends _$LoginIsLoading {
  @override
  bool build() => false;
  void setLoading(bool loading) => state = loading;
}
