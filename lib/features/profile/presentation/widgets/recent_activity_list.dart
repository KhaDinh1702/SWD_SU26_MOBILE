import 'package:flutter/material.dart';
import 'package:wave/core/theme/app_colors.dart';

class _ActivityItem {
  final String title;
  final String subtitle;
  final String points;
  final IconData icon;
  final Color accentColor;
  final String serviceTag;
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.icon,
    required this.accentColor,
    required this.serviceTag,
  });
}

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _ActivityItem(
        title: 'Rửa Cơ Bản',
        subtitle: '2 ngày trước · Biển số: 51F-123.45',
        points: '+50 điểm',
        icon: Icons.local_car_wash,
        accentColor: AppColors.primaryBlue,
        serviceTag: 'Tiêu chuẩn',
      ),
      const _ActivityItem(
        title: 'Rửa Cao Cấp',
        subtitle: '1 tuần trước · Biển số: 51F-123.45',
        points: '+120 điểm',
        icon: Icons.auto_awesome,
        accentColor: Color(0xFF9B72CF),
        serviceTag: 'Premium',
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: item.accentColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.serviceTag,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: item.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.accentColor,
                    item.accentColor.withValues(alpha: 0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.points,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
