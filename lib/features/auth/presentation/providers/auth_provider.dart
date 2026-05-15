import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/auth_state.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    // T-06: stub only — returns initial state
    // T-07 replaces this entirely with onAuthStateChange listener
    return const AuthInitial();
  }
}
