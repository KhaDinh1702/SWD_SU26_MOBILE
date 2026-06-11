import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/washer/data/models/washer_order_model.dart';
import 'package:wave/features/washer/presentation/pages/washer_detail_page.dart';
import 'package:wave/features/washer/presentation/providers/washer_provider.dart';
import 'package:wave/features/washer/presentation/widgets/washer_badges.dart';

/// Bộ lọc nhanh theo khoảng thời gian hoàn thành.
enum _DateFilter { all, today, yesterday, last7, custom }

class WasherCompletedPage extends ConsumerStatefulWidget {
  const WasherCompletedPage({super.key});

  @override
  ConsumerState<WasherCompletedPage> createState() =>
      _WasherCompletedPageState();
}

class _WasherCompletedPageState extends ConsumerState<WasherCompletedPage> {
  String _query = '';
  _DateFilter _filter = _DateFilter.all;
  DateTime? _customDay; // ngày cụ thể (chỉ y/m/d) khi _filter == custom

  bool _isDone(WasherOrderModel o) => o.isCompleted;

  /// Thời điểm hoàn thành (local). Ưu tiên finishedAt, fallback createdAt.
  DateTime? _completedAt(WasherOrderModel o) {
    final iso = o.finishedAt.isNotEmpty ? o.finishedAt : o.createdAt;
    return DateTime.tryParse(iso)?.toLocal();
  }

  bool _matchesDate(WasherOrderModel o) {
    if (_filter == _DateFilter.all) return true;
    final dt = _completedAt(o);
    if (dt == null) return false;
    final day = DateTime(dt.year, dt.month, dt.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_filter) {
      case _DateFilter.today:
        return day == today;
      case _DateFilter.yesterday:
        return day == today.subtract(const Duration(days: 1));
      case _DateFilter.last7:
        return !day.isBefore(today.subtract(const Duration(days: 6)));
      case _DateFilter.custom:
        if (_customDay == null) return true;
        return day == _customDay;
      case _DateFilter.all:
        return true;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDay ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'Lọc theo ngày hoàn thành',
    );
    if (picked != null) {
      setState(() {
        _customDay = DateTime(picked.year, picked.month, picked.day);
        _filter = _DateFilter.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(washerWorkOrdersProvider);

    return Scaffold(
      backgroundColor: washerBg,
      appBar: AppBar(
        backgroundColor: washerBg,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Đã hoàn thành',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tìm biển số...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _FilterBar(
            filter: _filter,
            customDay: _customDay,
            onSelect: (f) => setState(() {
              _filter = f;
              if (f != _DateFilter.custom) _customDay = null;
            }),
            onPickDate: _pickDate,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                var list = orders.where(_isDone).where(_matchesDate).toList();
                if (_query.isNotEmpty) {
                  list = list
                      .where((o) =>
                          o.licensePlate.toLowerCase().contains(_query))
                      .toList();
                }
                if (list.isEmpty) {
                  return _Empty(
                    text: _filter == _DateFilter.all && _query.isEmpty
                        ? 'Chưa có công việc hoàn thành'
                        : 'Không có công việc khớp bộ lọc',
                  );
                }
                // Sắp xếp mới nhất lên đầu rồi gom theo ngày.
                list.sort((a, b) {
                  final da = _completedAt(a);
                  final db = _completedAt(b);
                  if (da == null) return 1;
                  if (db == null) return -1;
                  return db.compareTo(da);
                });
                final sections = _groupByDay(list);
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(washerWorkOrdersProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: sections.length,
                    itemBuilder: (context, i) => _DaySection(
                      section: sections[i],
                      onTapOrder: (o) => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => WasherDetailPage(order: o)),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const _Empty(text: 'Không tải được danh sách'),
            ),
          ),
        ],
      ),
    );
  }

  List<_DaySectionData> _groupByDay(List<WasherOrderModel> list) {
    final sections = <_DaySectionData>[];
    final indexByKey = <String, int>{};
    for (final o in list) {
      final dt = _completedAt(o);
      final key = dt == null
          ? '—'
          : '${dt.year}-${dt.month}-${dt.day}';
      final idx = indexByKey[key];
      if (idx == null) {
        indexByKey[key] = sections.length;
        sections.add(_DaySectionData(label: _dayLabel(dt), orders: [o]));
      } else {
        sections[idx].orders.add(o);
      }
    }
    return sections;
  }
}

/// Nhãn ngày thân thiện: Hôm nay / Hôm qua / dd/mm/yyyy.
String _dayLabel(DateTime? dt) {
  if (dt == null) return 'Không rõ ngày';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  if (day == today) return 'Hôm nay';
  if (day == today.subtract(const Duration(days: 1))) return 'Hôm qua';
  final dd = dt.day.toString().padLeft(2, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  return '$dd/$mo/${dt.year}';
}

class _DaySectionData {
  final String label;
  final List<WasherOrderModel> orders;
  _DaySectionData({required this.label, required this.orders});
}

class _DaySection extends StatelessWidget {
  final _DaySectionData section;
  final void Function(WasherOrderModel) onTapOrder;
  const _DaySection({required this.section, required this.onTapOrder});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
          child: Row(
            children: [
              Text(
                section.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${section.orders.length} xe',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final o in section.orders) ...[
          _CompletedCard(order: o, onTap: () => onTapOrder(o)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final _DateFilter filter;
  final DateTime? customDay;
  final ValueChanged<_DateFilter> onSelect;
  final VoidCallback onPickDate;
  const _FilterBar({
    required this.filter,
    required this.customDay,
    required this.onSelect,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    String customLabel() {
      if (customDay == null) return 'Chọn ngày';
      final dd = customDay!.day.toString().padLeft(2, '0');
      final mo = customDay!.month.toString().padLeft(2, '0');
      return '$dd/$mo';
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: 'Tất cả',
            selected: filter == _DateFilter.all,
            onTap: () => onSelect(_DateFilter.all),
          ),
          _Chip(
            label: 'Hôm nay',
            selected: filter == _DateFilter.today,
            onTap: () => onSelect(_DateFilter.today),
          ),
          _Chip(
            label: 'Hôm qua',
            selected: filter == _DateFilter.yesterday,
            onTap: () => onSelect(_DateFilter.yesterday),
          ),
          _Chip(
            label: '7 ngày',
            selected: filter == _DateFilter.last7,
            onTap: () => onSelect(_DateFilter.last7),
          ),
          _Chip(
            label: customLabel(),
            icon: Icons.calendar_today_rounded,
            selected: filter == _DateFilter.custom,
            onTap: onPickDate,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 14,
                    color: selected ? Colors.white : AppColors.textMedium),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final WasherOrderModel order;
  final VoidCallback onTap;
  const _CompletedCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final passed = order.qcPassed;
    final accent =
        passed ? const Color(0xFF2E9E5B) : const Color(0xFFE5484D);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LicensePlateChip(
                            plate: order.licensePlate.isEmpty
                                ? '—'
                                : order.licensePlate),
                        QcBadge(passed: passed),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      order.vehicleLabel,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (order.qcNote.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: washerBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '"${order.qcNote}"',
                          style: const TextStyle(
                            color: AppColors.textMedium,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 15, color: AppColors.textLight),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Hoàn thành: ${_formatCompleted(order.finishedAt)}',
                                  style: const TextStyle(
                                      color: AppColors.textMedium,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onTap,
                          child: const Text(
                            'Xem chi tiết',
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCompleted(String iso) {
  if (iso.isEmpty) return '—';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final t = dt.toLocal();
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  final dd = t.day.toString().padLeft(2, '0');
  final mo = t.month.toString().padLeft(2, '0');
  return '$hh:$mm • $dd/$mo/${t.year}';
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: AppColors.textMedium)),
        ],
      ),
    );
  }
}
