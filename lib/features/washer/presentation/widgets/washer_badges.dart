import 'package:flutter/material.dart';
import 'package:wave/core/theme/app_colors.dart';

/// Nền chung cho các màn của washer (xám nhạt mát hơn cream).
const washerBg = Color(0xFFF5F6FA);

/// Biển số xe dạng chip viền nhạt.
class LicensePlateChip extends StatelessWidget {
  final String plate;
  const LicensePlateChip({super.key, required this.plate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBlue.withValues(alpha: 0.6)),
      ),
      child: Text(
        plate,
        style: const TextStyle(
          color: AppColors.darkBlue,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Nhãn trạng thái xử lý của work-order (theo field `status` từ API).
class WorkStatusBadge extends StatelessWidget {
  final String status;
  const WorkStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E9E5B);
    const red = Color(0xFFE5484D);

    String text;
    Color color;
    bool solid = false; // nền đặc, chữ trắng
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'washing':
        text = 'ĐANG RỬA';
        color = green;
        solid = true;
        break;
      case 'finished':
      case 'done':
      case 'completed':
        text = 'HOÀN THÀNH';
        color = AppColors.primaryBlue;
        break;
      case 'qc':
      case 'qc_passed':
        text = 'QC ĐẠT';
        color = green;
        break;
      case 'qc_failed':
        text = 'QC KHÔNG ĐẠT';
        color = red;
        break;
      case 'returned':
        text = 'LÀM LẠI';
        color = red;
        break;
      case 'waiting':
        text = 'ĐANG CHỜ';
        color = AppColors.textLight;
        break;
      default:
        text = status.isEmpty ? '—' : status.toUpperCase();
        color = AppColors.textLight;
    }

    final bool subtle = color == AppColors.textLight;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: solid ? 12 : 8, vertical: 4),
      decoration: BoxDecoration(
        color: solid
            ? color
            : (subtle ? AppColors.divider : color.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(solid ? 20 : 8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: solid
              ? Colors.white
              : (subtle ? AppColors.textMedium : color),
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Nhãn kết quả QC (Đạt / Không đạt).
class QcBadge extends StatelessWidget {
  final bool passed;
  const QcBadge({super.key, required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed ? const Color(0xFF2E9E5B) : const Color(0xFFE5484D);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(passed ? Icons.check_circle : Icons.cancel, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          passed ? 'QC: ĐẠT' : 'QC: KHÔNG ĐẠT',
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ],
    );
  }
}
