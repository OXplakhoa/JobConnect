import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_deps.dart';
import '../providers/forgot_password_state.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(forgotPasswordStateNotifierProvider.notifier).setStatus(ForgotPasswordStatus.loading);

    final res = await ref.read(forgotPasswordUseCaseProvider).call(_emailController.text.trim());

    if (!mounted) return;

    res.fold(
      (failure) {
        ref.read(forgotPasswordStateNotifierProvider.notifier).setStatus(ForgotPasswordStatus.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ref.read(forgotPasswordStateNotifierProvider.notifier).setStatus(ForgotPasswordStatus.success);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: state == ForgotPasswordStatus.success
            ? _buildSuccessView()
            : _buildFormView(state),
      ),
    );
  }

  Widget _buildFormView(ForgotPasswordStatus state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nhập email của bạn để đặt lại mật khẩu.',
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state == ForgotPasswordStatus.loading ? null : _submit,
            child: state == ForgotPasswordStatus.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        const Text(
          AppStrings.forgotPasswordSuccess,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Quay lại Đăng nhập'),
        ),
      ],
    );
  }
}
