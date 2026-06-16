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
  bool _saving = false;

  final ImagePicker _picker = ImagePicker();

  /// Ảnh sau khi rửa — washer chụp trước khi bấm "Hoàn thành".
  final List<XFile> _checkoutPhotos = [];
  static const _maxCheckoutPhotos = 5;

  /// Đơn đầy đủ — khởi tạo từ order danh sách rồi thay bằng bản chi tiết.
  late WasherOrderModel _order;

  /// Đang tải chi tiết để lấy checkinPhotos / checkoutPhotos.
  bool _loadingDetail = true;

  /// Trạng thái hiện tại (thay đổi sau khi start/finish).
  late String _status;

  WasherOrderModel get _statusModel =>
      WasherOrderModel(id: '', status: _status);
  bool get _isWaiting => _statusModel.isWaiting;
  bool get _isRedo => _statusModel.isRedo;
  bool get _isInProgress => _statusModel.isInProgress && !_statusModel.isRedo;

  /// Đơn đã hoàn thành → trang chỉ để xem, không thêm ảnh, không nút thao tác.
  bool get _readOnly => _statusModel.isCompleted;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _status = widget.order.status;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final full = await ref
          .read(washerRepositoryProvider)
          .getWorkOrder(widget.order.id);
      if (!mounted) return;
      setState(() {
        _order = full;
        _status = full.status;
      });
    } catch (_) {
      // Giữ nguyên order từ danh sách nếu không tải được chi tiết.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _addCheckoutPhoto() async {
    if (_checkoutPhotos.length >= _maxCheckoutPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ tải lên tối đa $_maxCheckoutPhotos ảnh'),
        ),
      );
      return;
    }
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
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryBlue,
              ),
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
      if (file != null) setState(() => _checkoutPhotos.add(file));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể truy cập ảnh')));
      }
    }
  }

  Future<void> _start() async {
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(washerRepositoryProvider)
          .startWorkOrder(widget.order.id);
      ref.invalidate(washerWorkOrdersProvider);
      if (mounted) {
        setState(() => _status = updated.status);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã bắt đầu xử lý')));
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
      // Upload ảnh checkout lên Cloudinary, lấy danh sách URL.
      List<String> photoUrls = const [];
      if (_checkoutPhotos.isNotEmpty) {
        photoUrls = await ref
            .read(uploadApiProvider)
            .uploadImages(_checkoutPhotos);
      }
      final updated = await ref
          .read(washerRepositoryProvider)
          .finishWorkOrder(widget.order.id, photoUrls);
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
        title: const Text(
          'Chi tiết công việc',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: _loadingDetail
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _InfoCard(order: order),
                const SizedBox(height: 24),
                _CheckinPhotosSection(photos: order.checkinPhotos),
                const SizedBox(height: 20),
                if (_readOnly)
                  _NetworkPhotosSection(
                    icon: Icons.image_outlined,
                    title: 'Ảnh sau khi rửa (nghiệm thu)',
                    photos: order.checkoutPhotos,
                    emptyHint: 'Không có ảnh nghiệm thu.',
                  )
                else
                  _UploadPhotosSection(
                    photos: _checkoutPhotos,
                    onAdd: _addCheckoutPhoto,
                    onRemove: (i) =>
                        setState(() => _checkoutPhotos.removeAt(i)),
                  ),
                if (order.qcNote.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Ghi chú QC',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC0392B),
                            ),
                          ),
                          TextSpan(
                            text: order.qcNote,
                            style: const TextStyle(color: AppColors.textMedium),
                          ),
                        ],
                      ),
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
                child: _buildPrimaryAction(),
              ),
            ),
    );
  }

  Widget _buildPrimaryAction() {
    final spinner = _saving
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : null;

    if (_isWaiting) {
      return ElevatedButton.icon(
        onPressed: _saving ? null : _start,
        icon: spinner ?? const Icon(Icons.play_arrow_rounded),
        label: const Text('Bắt đầu làm việc'),
      );
    }

    if (_isRedo) {
      return ElevatedButton.icon(
        onPressed: _saving ? null : _start,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5484D),
          foregroundColor: Colors.white,
        ),
        icon: spinner ?? const Icon(Icons.refresh_rounded),
        label: const Text('Bắt đầu làm lại'),
      );
    }

    if (_isInProgress) {
      final isRedo = _order.isRedo;
      return ElevatedButton.icon(
        onPressed: _saving ? null : _finish,
        style: isRedo
            ? ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5484D),
                foregroundColor: Colors.white,
              )
            : null,
        icon:
            spinner ??
            Icon(
              isRedo
                  ? Icons.refresh_rounded
                  : Icons.check_circle_outline_rounded,
            ),
        label: Text(isRedo ? 'Hoàn thành (làm lại)' : 'Hoàn thành'),
      );
    }

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
                plate: order.licensePlate.isEmpty ? '—' : order.licensePlate,
              ),
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
                  value: order.serviceName.isEmpty ? '—' : order.serviceName,
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
        Text(
          label,
          style: const TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
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

/// Ảnh hiện trạng xe lúc nhận — do thu ngân chụp, chỉ xem để đối chiếu.
class _CheckinPhotosSection extends StatelessWidget {
  final List<String> photos;
  const _CheckinPhotosSection({required this.photos});

  @override
  Widget build(BuildContext context) {
    return _NetworkPhotosSection(
      icon: Icons.photo_camera_outlined,
      title: 'Ảnh trước khi rửa (hiện trạng lúc nhận)',
      photos: photos,
      emptyHint:
          'Thu ngân chưa chụp ảnh hiện trạng xe lúc nhận. '
          'Ảnh sẽ hiển thị ở đây để bạn đối chiếu.',
    );
  }
}

/// Hiển thị danh sách ảnh URL từ server (read-only).
class _NetworkPhotosSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> photos;
  final String emptyHint;
  const _NetworkPhotosSection({
    required this.icon,
    required this.title,
    required this.photos,
    required this.emptyHint,
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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
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
            child: Text(
              emptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
              separatorBuilder: (_, _) => const SizedBox(width: 10),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (c, e, s) => Container(
                    width: 104,
                    height: 104,
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Section upload ảnh checkout (washer chụp sau khi rửa xong).
class _UploadPhotosSection extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  const _UploadPhotosSection({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.image_outlined, size: 18, color: AppColors.textMedium),
            SizedBox(width: 8),
            Text(
              'Ảnh sau khi rửa (nghiệm thu)',
              style: TextStyle(
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
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) =>
                    _Thumb(file: photos[i], onRemove: () => onRemove(i)),
              ),
            ),
          ),
        _AddPhotoBox(onTap: onAdd),
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
        painter: _DashedBorderPainter(color: AppColors.lightBlue, radius: 14),
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
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.darkBlue,
                ),
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
