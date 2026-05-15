import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_deps.dart';
import '../providers/login_state.dart';
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
        // Router will handle navigation based on auth state change
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

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.login)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Mật khẩu',
                controller: _passwordController,
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.login),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('HOẶC'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SocialLoginButton(
                text: 'Đăng nhập bằng Google',
                iconUrl: 'assets/icons/google.png',
                onPressed: isLoading ? () {} : _loginWithGoogle,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Chưa có tài khoản? Đăng ký ngay'),
              ),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text('Quên mật khẩu?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
