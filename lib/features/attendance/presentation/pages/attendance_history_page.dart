import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/empty_view.dart';
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
  int _totalMissed = 0;
  List<AttendanceRecord> _allRecords = [];
  List<AttendanceRecord> _filteredRecords = [];
  bool _loading = true;
  
  // Filters
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  
  final List<String> _sessionTypes = ['All', 'Class', 'Mastery', 'Workshop', 'Study', 'PSL'];
  final List<String> _statusOptions = ['All', 'Present', 'Absent'];

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
        _store.getTotalMissed(),
        _store.getAllHistory(),
      ]);
      setState(() {
        _overallPercent = results[0] as double;
        _totalAttended = results[1] as int;
        _totalHeld = results[2] as int;
        _totalMissed = results[3] as int;
        _allRecords = results[4] as List<AttendanceRecord>;
        _applyFilters();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    var records = List<AttendanceRecord>.from(_allRecords);
    
    if (_selectedType != 'All') {
      records = records.where((r) => r.sessionType == _selectedType).toList();
    }
    
    if (_selectedStatus == 'Present') {
      records = records.where((r) => r.isPresent).toList();
    } else if (_selectedStatus == 'Absent') {
      records = records.where((r) => !r.isPresent).toList();
    }
    
    _filteredRecords = records;
  }

  void _onTypeChanged(String type) {
    setState(() {
      _selectedType = type;
      _applyFilters();
    });
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
      _applyFilters();
    });
  }

  Color _getStatusColor() {
    if (_overallPercent >= 90) return AppColors.success;
    if (_overallPercent >= 75) return AppColors.primary;
    if (_overallPercent >= 60) return Colors.orange;
    return AppColors.error;
  }

  /// Group records by date
  Map<String, List<AttendanceRecord>> _groupByDate(List<AttendanceRecord> records) {
    final grouped = <String, List<AttendanceRecord>>{};
    for (final record in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.date);
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingView(compact: true)
            : ResponsiveContainer(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                statusColor.withValues(alpha: 0.1),
                                theme.scaffoldBackgroundColor,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              // Circular progress
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: CircularProgressIndicator(
                                        value: _overallPercent / 100,
                                        strokeWidth: 12,
                                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                        color: statusColor,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_overallPercent.toStringAsFixed(1)}%',
                                          style: theme.textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Overall Attendance',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Stats row
                              Row(
                                children: [
                                  _StatCard(
                                    icon: Icons.check_circle_rounded,
                                    iconColor: AppColors.success,
                                    label: 'Attended',
                                    value: '$_totalAttended',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatCard(
                                    icon: Icons.cancel_rounded,
                                    iconColor: AppColors.error,
                                    label: 'Missed',
                                    value: '$_totalMissed',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatCard(
                                    icon: Icons.event_rounded,
                                    iconColor: AppColors.primary,
                                    label: 'Total',
                                    value: '$_totalHeld',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Filter Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filter by Type',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _sessionTypes.map((type) {
                                    final isSelected = _selectedType == type;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(type),
                                        selected: isSelected,
                                        onSelected: (_) => _onTypeChanged(type),
                                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                        checkmarkColor: AppColors.primary,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Filter by Status',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: _statusOptions.map((status) {
                                  final isSelected = _selectedStatus == status;
                                  Color chipColor;
                                  if (status == 'Present') {
                                    chipColor = AppColors.success;
                                  } else if (status == 'Absent') {
                                    chipColor = AppColors.error;
                                  } else {
                                    chipColor = AppColors.primary;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(status),
                                      selected: isSelected,
                                      onSelected: (_) => _onStatusChanged(status),
                                      selectedColor: chipColor.withValues(alpha: 0.2),
                                      checkmarkColor: chipColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // History List Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Attendance Records',
                                style: theme.textTheme.titleLarge,
                              ),
                              Text(
                                '${_filteredRecords.length} records',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // History List (grouped by date)
                        if (_filteredRecords.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: EmptyView(
                              message: _allRecords.isEmpty
                                  ? 'No attendance records yet.\nAdd sessions and mark attendance to see your history.'
                                  : 'No records match your filters.',
                              icon: Icons.history_rounded,
                            ),
                          )
                        else
                          ..._buildGroupedHistory(theme),
                          
                        // Navigation to Schedule
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(RouteConstants.schedule),
                              icon: const Icon(Icons.calendar_today_rounded),
                              label: const Text('View Schedule'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildGroupedHistory(ThemeData theme) {
    final grouped = _groupByDate(_filteredRecords);
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    
    final widgets = <Widget>[];
    
    for (final dateKey in sortedDates) {
      final date = DateTime.parse(dateKey);
      final records = grouped[dateKey]!;
      
      // Date header
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDateHeader(date),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${records.where((r) => r.isPresent).length}/${records.length} attended',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
      
      // Records for this date
      for (final record in records) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _AttendanceRecordTile(record: record),
          ),
        );
      }
    }
    
    return widgets;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDate = DateTime(date.year, date.month, date.day);
    
    if (recordDate == today) return 'Today';
    if (recordDate == yesterday) return 'Yesterday';
    if (now.difference(date).inDays < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d, yyyy').format(date);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AluCard(
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRecordTile extends StatelessWidget {
  const _AttendanceRecordTile({required this.record});

  final AttendanceRecord record;

  IconData _getSessionIcon(String type) {
    switch (type) {
      case 'Class':
        return Icons.school_rounded;
      case 'Mastery':
        return Icons.psychology_rounded;
      case 'Workshop':
        return Icons.build_rounded;
      case 'Study':
        return Icons.menu_book_rounded;
      case 'PSL':
        return Icons.groups_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AluCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getSessionIcon(record.sessionType),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.sessionTitle,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      record.time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.sessionType,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: record.isPresent
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: record.isPresent
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  record.isPresent ? Icons.check_rounded : Icons.close_rounded,
                  size: 14,
                  color: record.isPresent ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  record.isPresent ? 'Present' : 'Absent',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: record.isPresent ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
