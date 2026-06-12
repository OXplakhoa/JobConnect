import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/connection_loop_logo.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../providers/auth_deps.dart';
import '../providers/auth_provider.dart';
import '../providers/login_state.dart';
import '../../domain/entities/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(loginIsLoadingProvider.notifier).setLoading(true);

    final res = await ref.read(loginUseCaseProvider).call(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    ref.read(loginIsLoadingProvider.notifier).setLoading(false);

    res.fold(
      (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        if (!mounted) return;
        // Login API succeeded — wait for profile fetch + router redirect
      },
    );
  }

  Future<void> _loginWithGoogle() async {
    ref.read(loginIsLoadingProvider.notifier).setLoading(true);

    final res = await ref.read(googleLoginUseCaseProvider).call();

    ref.read(loginIsLoadingProvider.notifier).setLoading(false);

    res.fold(
      (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        // Router will handle navigation
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginIsLoadingProvider);
    final authState = ref.watch(authProvider);

    // Show auth errors (e.g. profile fetch failed after login)
    if (authState is AuthError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.message)),
        );
      });
    }

    // The auth flow is brand canvas — always Light Minimal, never tinted by the
    // OS dark setting. Pin the subtree to the light theme so inherited text /
    // field / button colors resolve light regardless of system brightness.
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Loop mark + serif title — the utility-tier hero moment.
                  const ConnectionLoopLogo(size: 52, showWordmark: false),
                  const SizedBox(height: 24),
                  const Text(AppStrings.login, style: AppTextStyles.display),
                  const SizedBox(height: 6),
                  Text(
                    'Chào mừng trở lại JobConnect',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    label: 'Mật khẩu',
                    controller: _passwordController,
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(
                        'Quên mật khẩu?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PremiumButton(
                    label: AppStrings.login,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    text: 'Tiếp tục với Google',
                    iconUrl: 'assets/icons/google.png',
                    onPressed: isLoading ? () {} : _loginWithGoogle,
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Chưa có tài khoản? ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () => context.push('/register'),
                              child: Text(
                                'Đăng ký',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
