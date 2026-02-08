import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_button.dart';
import '../../../../shared/widgets/alu_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../domain/validators/auth_validators.dart';
import '../view_models/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(LoginViewModel vm) async {
    vm.clearErrors();
    final success = await vm.submit(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      context.go(RouteConstants.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.aluNavy,
        body: SafeArea(
          child: ResponsiveContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Consumer<LoginViewModel>(
                builder: (context, vm, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        // Logo placeholder
                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 48,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.appTagline,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        AluTextField(
                          controller: _emailController,
                          label: 'ALU Student Email',
                          hint: 'student.name@alustudent.com',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          errorText: vm.emailError,
                          validator: (v) => vm.emailError ?? AuthValidators.email(v),
                        ),
                        const SizedBox(height: 16),
                        AluTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          obscureText: vm.obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          errorText: vm.passwordError,
                          validator: (v) => vm.passwordError ?? AuthValidators.password(v),
                          suffixIcon: IconButton(
                            icon: Icon(
                              vm.obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            onPressed: () =>
                                vm.setObscurePassword(!vm.obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Forgot password
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        if (vm.submitError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            vm.submitError!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        AluButton(
                          label: 'Login',
                          icon: Icons.login_rounded,
                          loading: vm.isLoading,
                          onPressed: () => _submit(vm),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(RouteConstants.createAccount),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
