import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../data/stores/attendance_store.dart';
import '../../domain/models/attendance_record.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key, required this.store});

  final AttendanceStore store;

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  AttendanceStore get _store => widget.store;

  double _overallPercent = 0;
  int _totalAttended = 0;
  int _totalHeld = 0;
  double _monthlyProgress = 0;
  List<AttendanceRecord> _allRecords = [];
  List<AttendanceRecord> _filteredRecords = [];
  bool _loading = true;

  String _selectedType = 'All Sessions';
  final List<String> _sessionTypes = [
    'All Sessions',
    'Class',
    'Mastery',
    'Workshop',
    'Study',
    'PSL',
  ];

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
        _store.getMonthlyProgress(),
        _store.getAllHistory(),
      ]);
      setState(() {
        _overallPercent = results[0] as double;
        _totalAttended = results[1] as int;
        _totalHeld = results[2] as int;
        _monthlyProgress = results[3] as double;
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
    if (_selectedType != 'All Sessions') {
      records = records.where((r) => r.sessionType == _selectedType).toList();
    }
    _filteredRecords = records;
  }

  void _onTypeChanged(String type) {
    setState(() {
      _selectedType = type;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Attendance History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: _loading
          ? const LoadingView(compact: true)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _buildHeroSection(),
                  _buildMonthlyProgress(),
                  _buildStatCards(),
                  _buildFilterSection(),
                  _buildRecentActivityHeader(),
                  _buildActivityList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  // ─── Hero Section with Circular Progress ──────────────────────────
  Widget _buildHeroSection() {
    final pct = (_overallPercent / 100).clamp(0.0, 1.0);
    final statusColor = _overallPercent >= 75
        ? AppColors.primary
        : _overallPercent >= 50
            ? Colors.orange
            : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceDark,
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  color: statusColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_overallPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'OVERALL',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Monthly Progress Bar ─────────────────────────────────────────
  Widget _buildMonthlyProgress() {
    final isPositive = _monthlyProgress >= 0;
    final progressText = isPositive
        ? '+${_monthlyProgress.toStringAsFixed(1)}% vs last month'
        : '${_monthlyProgress.toStringAsFixed(1)}% vs last month';
    final progressColor = isPositive ? AppColors.success : AppColors.error;
    final pct = (_overallPercent / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  color: progressColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Stat Cards (Total Attended / Total Held) ────────────────────
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'TOTAL ATTENDED',
              value: '$_totalAttended',
              unit: 'sessions',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'TOTAL HELD',
              value: '$_totalHeld',
              unit: 'sessions',
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────────
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER BY TYPE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _sessionTypes.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: type,
                    isSelected: isSelected,
                    onTap: () => _onTypeChanged(type),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent Activity Header ───────────────────────────────────────
  Widget _buildRecentActivityHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => context.push(RouteConstants.schedule),
            child: const Text(
              'View Calendar',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Activity List ────────────────────────────────────────────────
  Widget _buildActivityList() {
    if (_filteredRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: EmptyView(
          message: _allRecords.isEmpty
              ? 'No attendance records yet.\nAdd sessions and mark attendance to see your history.'
              : 'No records match your filter.',
          icon: Icons.history_rounded,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _filteredRecords.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ActivityCard(record: record),
          );
        }).toList(),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final missed = _totalHeld - _totalAttended;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Attendance Summary',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Overall Attendance', '${_overallPercent.toStringAsFixed(1)}%'),
            _infoRow('Sessions Attended', '$_totalAttended'),
            _infoRow('Sessions Missed', '$missed'),
            _infoRow('Total Sessions', '$_totalHeld'),
            const SizedBox(height: 12),
            if (_overallPercent < 75)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your attendance is below 75%. Aim to attend more sessions.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// Private Widgets
// ═════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (label != 'All Sessions') ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isSelected ? AppColors.primary : Colors.white38,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.record});

  final AttendanceRecord record;

  IconData _getSessionIcon(String type) {
    switch (type) {
      case 'Class':
        return Icons.school_rounded;
      case 'Mastery':
        return Icons.groups_rounded;
      case 'Workshop':
        return Icons.build_rounded;
      case 'Study':
        return Icons.menu_book_rounded;
      case 'PSL':
        return Icons.mic_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'Class':
        return AppColors.primary;
      case 'Mastery':
        return AppColors.info;
      case 'Workshop':
        return Colors.purple;
      case 'Study':
        return AppColors.success;
      case 'PSL':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconBg = _getIconBgColor(record.sessionType);
    final dateStr = DateFormat('MMM d').format(record.date);
    final timeStr = record.time.isNotEmpty
        ? record.time
        : DateFormat('hh:mm a').format(record.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSessionIcon(record.sessionType),
              color: iconBg,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.sessionTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$dateStr \u2022 $timeStr',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Present / Absent badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: record.isPresent
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: record.isPresent
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              record.isPresent ? 'PRESENT' : 'ABSENT',
              style: TextStyle(
                color: record.isPresent ? AppColors.success : AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
