import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forgot_password_state.g.dart';

enum ForgotPasswordStatus { idle, loading, success }

@riverpod
class ForgotPasswordStateNotifier extends _$ForgotPasswordStateNotifier {
  @override
  ForgotPasswordStatus build() => ForgotPasswordStatus.idle;

  void setStatus(ForgotPasswordStatus status) => state = status;
}
