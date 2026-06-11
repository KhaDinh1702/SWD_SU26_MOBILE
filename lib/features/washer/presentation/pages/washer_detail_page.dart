import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wave/core/network/error_parser.dart';
import 'package:wave/core/network/upload_api.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/washer/data/models/washer_order_model.dart';
import 'package:wave/features/washer/presentation/providers/washer_provider.dart';
import 'package:wave/features/washer/presentation/widgets/washer_badges.dart';

class WasherDetailPage extends ConsumerStatefulWidget {
  final WasherOrderModel order;
  const WasherDetailPage({super.key, required this.order});

  @override
  ConsumerState<WasherDetailPage> createState() => _WasherDetailPageState();
}

class _WasherDetailPageState extends ConsumerState<WasherDetailPage> {
  late List<ChecklistItemModel> _checklist;
  bool _saving = false;

  final ImagePicker _picker = ImagePicker();

  /// Ảnh nghiệm thu sau khi rửa do washer chụp (tối đa 5 ảnh/đơn).
  /// Ảnh "trước khi rửa" do thu ngân chụp lúc nhận xe → lấy từ
  /// [WasherOrderModel.checkinPhotos], washer chỉ xem để đối chiếu.
  final List<XFile> _afterPhotos = [];
  static const _maxAfterPhotos = 5;

  static const _fallbackChecklist = [
    ChecklistItemModel(label: 'Rửa gầm & hốc bánh', group: 'Ngoại thất'),
    ChecklistItemModel(label: 'Tẩy nhựa đường & Côn trùng', group: 'Ngoại thất'),
    ChecklistItemModel(label: 'Hút bụi sàn & Thảm', group: 'Nội thất'),
    ChecklistItemModel(label: 'Vệ sinh Taplo & Cánh cửa', group: 'Nội thất'),
    ChecklistItemModel(label: 'Dưỡng bóng lốp', group: 'Lốp & Mâm'),
  ];

  /// True nếu checklist đến từ server (có index hợp lệ để PATCH).
  bool _hasServerChecklist = false;

  /// Đơn đầy đủ — khởi tạo từ order danh sách rồi thay bằng bản chi tiết
  /// (kèm trạng thái `done` đã lưu) sau khi tải từ server.
  late WasherOrderModel _order;

  /// Đang tải chi tiết work-order để lấy checklist đã lưu.
  bool _loadingDetail = true;

  /// Trạng thái hiện tại (thay đổi sau khi start/finish).
  late String _status;

  /// Đơn ảo chỉ mang [_status] để tái dùng logic phân loại của model.
  WasherOrderModel get _statusModel => WasherOrderModel(id: '', status: _status);
  bool get _isWaiting => _statusModel.isWaiting;
  bool get _isInProgress => _statusModel.isInProgress;

  /// Đơn đã hoàn thành (đang/đã QC, huỷ...) → trang chỉ để xem,
  /// không tick checklist, không thêm/chụp ảnh, không nút thao tác.
  bool get _readOnly => _statusModel.isCompleted;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _status = widget.order.status;
    _applyChecklistFrom(widget.order);
    _loadDetail();
  }

  /// Dựng lại checklist từ một order; dùng dữ liệu server nếu có,
  /// ngược lại rơi về danh sách mặc định (tất cả chưa tick).
  void _applyChecklistFrom(WasherOrderModel order) {
    _hasServerChecklist = order.checklist.isNotEmpty;
    _checklist = _hasServerChecklist
        ? order.checklist.map((e) => e.copyWith()).toList()
        : List.of(_fallbackChecklist);
  }

  /// Tải work-order chi tiết để lấy trạng thái `done` của từng mục checklist
  /// (API danh sách không trả về). Lỗi → giữ nguyên dữ liệu sẵn có.
  Future<void> _loadDetail() async {
    try {
      final full =
          await ref.read(washerRepositoryProvider).getWorkOrder(widget.order.id);
      if (!mounted) return;
      setState(() {
        _order = full;
        _status = full.status;
        _applyChecklistFrom(full);
      });
    } catch (_) {
      // Giữ nguyên order từ danh sách nếu không tải được chi tiết.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Map<String, List<ChecklistItemModel>> get _grouped {
    final map = <String, List<ChecklistItemModel>>{};
    for (final item in _checklist) {
      final g = item.group.isEmpty ? 'Hạng mục' : item.group;
      map.putIfAbsent(g, () => []).add(item);
    }
    return map;
  }

  void _toggle(ChecklistItemModel item, bool? value) {
    setState(() {
      final i = _checklist.indexOf(item);
      if (i != -1) _checklist[i] = item.copyWith(done: value ?? false);
    });
  }

  Future<void> _addAfterPhoto() async {
    if (_afterPhotos.length >= _maxAfterPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ tải lên tối đa $_maxAfterPhotos ảnh')),
      );
      return;
    }
    await _addPhoto(_afterPhotos);
  }

  Future<void> _addPhoto(List<XFile> target) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.primaryBlue),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primaryBlue),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (file != null) setState(() => target.add(file));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể truy cập ảnh')),
        );
      }
    }
  }

  Future<void> _start() async {
    setState(() => _saving = true);
    try {
      final updated =
          await ref.read(washerRepositoryProvider).startWorkOrder(widget.order.id);
      ref.invalidate(washerWorkOrdersProvider);
      if (mounted) {
        setState(() => _status = updated.status);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bắt đầu xử lý')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không bắt đầu được, thử lại sau')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(washerRepositoryProvider);
      // Tải ảnh nghiệm thu sau khi rửa lên Cloudinary trước khi chốt đơn.
      if (_afterPhotos.isNotEmpty) {
        await ref.read(uploadApiProvider).uploadImages(_afterPhotos);
      }
      // Đồng bộ từng mục checklist theo index trước khi hoàn thành.
      if (_hasServerChecklist) {
        for (var i = 0; i < _checklist.length; i++) {
          await repo.updateChecklistItem(
              widget.order.id, i, _checklist[i].done);
        }
      }
      final updated = await repo.finishWorkOrder(widget.order.id);
      ref.invalidate(washerWorkOrdersProvider);
      if (mounted) {
        setState(() => _status = updated.status);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hoàn thành, chờ kiểm tra (QC)')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể hoàn thành: ${parseError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      backgroundColor: washerBg,
      appBar: AppBar(
        backgroundColor: washerBg,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text('Chi tiết công việc',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _InfoCard(order: order),
          const SizedBox(height: 24),
          if (_loadingDetail)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            for (final entry in _grouped.entries) ...[
              _GroupHeader(title: entry.key),
              const SizedBox(height: 10),
              ...entry.value.map(_buildChecklistTile),
              const SizedBox(height: 16),
            ],
          _CheckinPhotosSection(photos: order.checkinPhotos),
          if (!_readOnly) ...[
            const SizedBox(height: 20),
            _PhotoSection(
              icon: Icons.image_outlined,
              title: 'Ảnh sau khi rửa (nghiệm thu)',
              photos: _afterPhotos,
              onAdd: _addAfterPhoto,
              onRemove: (i) => setState(() => _afterPhotos.removeAt(i)),
            ),
          ],
          const SizedBox(height: 24),
          if (order.qcNote.isNotEmpty) ...[
            const Text('Ghi chú QC',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDark)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text.rich(
                TextSpan(children: [
                  const TextSpan(
                      text: 'Lưu ý: ',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC0392B))),
                  TextSpan(
                      text: order.qcNote,
                      style: const TextStyle(color: AppColors.textMedium)),
                ]),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _readOnly
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _applyChecklistFrom(_order)),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Làm mới'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMedium,
                        side: const BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPrimaryAction()),
                  ],
                ),
              ),
            ),
    );
  }

  /// Nút hành động chính đổi theo trạng thái:
  /// waiting → Bắt đầu · đang rửa → Hoàn thành · còn lại → khoá.
  Widget _buildPrimaryAction() {
    final spinner = _saving
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : null;

    if (_isWaiting) {
      return ElevatedButton.icon(
        onPressed: _saving ? null : _start,
        icon: spinner ?? const Icon(Icons.play_arrow_rounded),
        label: const Text('Bắt đầu làm việc'),
      );
    }

    if (_isInProgress) {
      return ElevatedButton.icon(
        onPressed: _saving ? null : _finish,
        icon: spinner ?? const Icon(Icons.check_circle_outline_rounded),
        label: const Text('Hoàn thành'),
      );
    }

    // quality_check / done / cancelled... → không thao tác được nữa.
    return ElevatedButton.icon(
      onPressed: null,
      icon: const Icon(Icons.lock_outline_rounded),
      label: Text(_lockedLabel()),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: AppColors.divider,
        disabledForegroundColor: AppColors.textMedium,
      ),
    );
  }

  String _lockedLabel() {
    switch (_status.toLowerCase()) {
      case 'quality_check':
      case 'qc':
        return 'Đang chờ QC';
      case 'qc_passed':
      case 'done':
      case 'finished':
      case 'completed':
        return 'Đã hoàn thành';
      case 'qc_failed':
      case 'returned':
        return 'Cần làm lại';
      case 'cancelled':
        return 'Đã huỷ';
      default:
        return 'Không khả dụng';
    }
  }

  Widget _buildChecklistTile(ChecklistItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _readOnly
          ? ListTile(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              trailing: Icon(
                item.done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: item.done ? AppColors.primaryBlue : AppColors.textLight,
              ),
              title: Text(
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            )
          : CheckboxListTile(
              value: item.done,
              onChanged: (v) => _toggle(item, v),
              controlAffinity: ListTileControlAffinity.trailing,
              activeColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final WasherOrderModel order;
  const _InfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LicensePlateChip(
                  plate: order.licensePlate.isEmpty ? '—' : order.licensePlate),
              WorkStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            order.vehicleLabel,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: _MetaCol(
                  label: 'Mã phiếu',
                  value: order.code.isEmpty ? '—' : '#${order.code}',
                ),
              ),
              Expanded(
                child: _MetaCol(
                  label: 'Gói dịch vụ',
                  value:
                      order.serviceName.isEmpty ? '—' : order.serviceName,
                  valueColor: const Color(0xFF2E9E5B),
                ),
              ),
            ],
          ),
          if (order.stationName.isNotEmpty || order.estimatedMinutes > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetaCol(
                    label: 'Khu vực',
                    value: order.stationName.isEmpty ? '—' : order.stationName,
                  ),
                ),
                Expanded(
                  child: _MetaCol(
                    label: 'Thời gian dự kiến',
                    value: order.estimatedMinutes > 0
                        ? '${order.estimatedMinutes} phút'
                        : '—',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaCol extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _MetaCol({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<XFile> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  const _PhotoSection({
    required this.icon,
    required this.title,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMedium),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, i) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _Thumb(
                  file: photos[i],
                  onRemove: () => onRemove(i),
                ),
              ),
            ),
          ),
        _AddPhotoBox(onTap: onAdd),
      ],
    );
  }
}

/// Ảnh hiện trạng xe lúc nhận, do thu ngân chụp — chỉ xem để đối chiếu.
class _CheckinPhotosSection extends StatelessWidget {
  final List<String> photos;
  const _CheckinPhotosSection({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.photo_camera_outlined,
                size: 18, color: AppColors.textMedium),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ảnh trước khi rửa (hiện trạng lúc nhận)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (photos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Text(
              'Thu ngân chưa chụp ảnh hiện trạng xe lúc nhận. '
              'Ảnh sẽ hiển thị ở đây để bạn đối chiếu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMedium,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          )
        else
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, i) => const SizedBox(width: 10),
              itemBuilder: (context, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  photos[i],
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                  loadingBuilder: (c, child, progress) => progress == null
                      ? child
                      : Container(
                          width: 104,
                          height: 104,
                          color: AppColors.divider,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (c, e, s) => Container(
                    width: 104,
                    height: 104,
                    color: AppColors.divider,
                    child: const Icon(Icons.broken_image_outlined,
                        color: AppColors.textLight),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;
  const _Thumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(file.path),
            width: 104,
            height: 104,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoBox extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoBox({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.lightBlue,
          radius: 14,
        ),
        child: Container(
          width: double.infinity,
          height: 120,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_a_photo_outlined,
                    color: AppColors.darkBlue),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thêm ảnh',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, this.radius = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 6.0;
    const dashGap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (title) {
      case 'Ngoại thất':
        icon = Icons.directions_car_filled_outlined;
        break;
      case 'Nội thất':
        icon = Icons.airline_seat_recline_normal_outlined;
        break;
      case 'Lốp & Mâm':
        icon = Icons.tire_repair_outlined;
        break;
      default:
        icon = Icons.checklist_rounded;
    }
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
