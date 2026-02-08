import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_button.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/data/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final repo = await AuthRepository.create();
    final user = await repo.getCurrentUser();
    if (mounted) setState(() { _user = user; _loading = false; });
  }

  Future<void> _logout() async {
    final repo = await AuthRepository.create();
    await repo.logout();
    if (!mounted) return;
    context.go(RouteConstants.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final displayName = _user?.fullName ?? 'User';
    final displayEmail = _user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: AppConstants.bottomNavHeight + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        displayEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AluCard(
                  onTap: () => context.push(RouteConstants.schedule),
                  child: const ListTile(
                    leading: Icon(Icons.calendar_month_rounded),
                    title: Text('Schedule'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                AluCard(
                  onTap: () => context.push(RouteConstants.attendanceHistory),
                  child: const ListTile(
                    leading: Icon(Icons.analytics_rounded),
                    title: Text('Attendance History'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                AluCard(
                  onTap: () {},
                  child: const ListTile(
                    leading: Icon(Icons.settings_rounded),
                    title: Text('Settings'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                AluButton(
                  label: 'Log Out',
                  style: AluButtonStyle.secondary,
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
