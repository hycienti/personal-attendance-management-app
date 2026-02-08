import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/validators/auth_validators.dart';
import '../../../../shared/widgets/alu_button.dart';
import '../../../../shared/widgets/alu_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../view_models/create_account_view_model.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(CreateAccountViewModel vm) async {
    vm.clearErrors();
    final success = await vm.submit(
      fullName: _fullNameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      context.go(RouteConstants.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateAccountViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.aluNavy,
        appBar: AppBar(
          backgroundColor: AppColors.aluNavy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Create Account'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ResponsiveContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Consumer<CreateAccountViewModel>(
                builder: (context, vm, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Join the ALU Community',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Register with your student credentials to start managing your academic life.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 24),
                        AluTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          errorText: vm.fullNameError,
                          validator: (v) =>
                              vm.fullNameError ?? AuthValidators.fullName(v),
                        ),
                        const SizedBox(height: 16),
                        AluTextField(
                          controller: _studentIdController,
                          label: 'ALU Student ID',
                          hint: 'e.g. 100245',
                          errorText: vm.studentIdError,
                          validator: (v) =>
                              vm.studentIdError ?? AuthValidators.studentId(v),
                        ),
                        const SizedBox(height: 16),
                        AluTextField(
                          controller: _emailController,
                          label: 'Student Email',
                          hint: 'student@alueducation.com',
                          keyboardType: TextInputType.emailAddress,
                          errorText: vm.emailError,
                          validator: (v) =>
                              vm.emailError ?? AuthValidators.email(v),
                        ),
                        const SizedBox(height: 16),
                        AluTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Create a password',
                          obscureText: vm.obscurePassword,
                          errorText: vm.passwordError,
                          validator: (v) =>
                              vm.passwordError ?? AuthValidators.password(v),
                          suffixIcon: IconButton(
                            icon: Icon(
                              vm.obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.white54,
                            ),
                            onPressed: () =>
                                vm.setObscurePassword(!vm.obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AluTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          obscureText: vm.obscureConfirm,
                          errorText: vm.confirmPasswordError,
                          validator: (v) => vm.confirmPasswordError ??
                              AuthValidators.confirmPassword(
                                  v, _passwordController.text),
                          suffixIcon: IconButton(
                            icon: Icon(
                              vm.obscureConfirm
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.white54,
                            ),
                            onPressed: () =>
                                vm.setObscureConfirm(!vm.obscureConfirm),
                          ),
                        ),
                        if (vm.submitError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            vm.submitError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 32),
                        AluButton(
                          label: 'Create Account',
                          loading: vm.isLoading,
                          onPressed: () => _submit(vm),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () => context.push(RouteConstants.login),
                              child: const Text('Log In'),
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
