import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../data/stores/attendance_store.dart';
import '../../domain/models/attendance_record.dart';

class AttendanceHistoryPage extends StatefulWidget {
  AttendanceHistoryPage({super.key, AttendanceStore? store})
      : _store = store ?? MockAttendanceStore();

  final AttendanceStore _store;

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  AttendanceStore get _store => widget._store;
  double _overallPercent = 0;
  int _totalAttended = 0;
  int _totalHeld = 0;
  List<AttendanceRecord> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _store.getOverallPercent(),
        _store.getTotalAttended(),
        _store.getTotalHeld(),
        _store.getRecentActivity(),
      ]);
      setState(() {
        _overallPercent = results[0] as double;
        _totalAttended = results[1] as int;
        _totalHeld = results[2] as int;
        _recent = results[3] as List<AttendanceRecord>;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingView(compact: true)
            : ResponsiveContainer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              theme.scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: _overallPercent / 100,
                                    strokeWidth: 12,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: AppColors.primary,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_overallPercent.toInt()}%',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                      Text(
                                        'Overall',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _overallPercent / 100,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monthly Progress',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '+2.4% vs last month',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AluCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL ATTENDED',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_totalAttended',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  Text(
                                    'sessions',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AluCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL HELD',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_totalHeld',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  Text(
                                    'sessions',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: theme.textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(RouteConstants.schedule),
                            child: const Text('View Calendar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._recent.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AluCard(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.school_rounded,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.sessionTitle,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      Text(
                                        '${DateFormat('MMM d').format(r.date)} • ${r.time}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: r.isPresent
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: r.isPresent
                                          ? AppColors.success.withValues(alpha: 0.3)
                                          : AppColors.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    r.isPresent ? 'Present' : 'Absent',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: r.isPresent
                                          ? AppColors.success
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
