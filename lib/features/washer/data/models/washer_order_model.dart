class ChecklistItemModel {
  final String label;
  final bool done;
  final String doneAt;
  final String group; // chỉ dùng để gom nhóm trên UI (server không trả)

  const ChecklistItemModel({
    this.label = '',
    this.done = false,
    this.doneAt = '',
    this.group = '',
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      label: (json['label'] ?? json['title'] ?? json['name'] ?? '').toString(),
      done: json['done'] ?? false,
      doneAt: (json['doneAt'] ?? '').toString(),
      group: (json['group'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'done': done};

  ChecklistItemModel copyWith({
    String? label,
    bool? done,
    String? doneAt,
    String? group,
  }) {
    return ChecklistItemModel(
      label: label ?? this.label,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      group: group ?? this.group,
    );
  }
}

class WasherOrderModel {
  final String id;
  final String orderId;
  final String code;
  final String licensePlate; // vehicleSnapshot.plate
  final String vehicleTypeName; // vehicleSnapshot.vehicleTypeName
  final String vehicleColor; // vehicleSnapshot.color
  final String serviceName;
  final String status; // waiting / in_progress / finished / qc_passed ...
  final String stationName;
  final int estimatedMinutes;
  final String assignedWasherName;
  final String startedAt;
  final String finishedAt;
  final String createdAt;
  final bool qcPassed;
  final String qcNote;
  final List<String> checkinPhotos;
  final List<ChecklistItemModel> checklist;

  const WasherOrderModel({
    required this.id,
    this.orderId = '',
    this.code = '',
    this.licensePlate = '',
    this.vehicleTypeName = '',
    this.vehicleColor = '',
    this.serviceName = '',
    this.status = '',
    this.stationName = '',
    this.estimatedMinutes = 0,
    this.assignedWasherName = '',
    this.startedAt = '',
    this.finishedAt = '',
    this.createdAt = '',
    this.qcPassed = false,
    this.qcNote = '',
    this.checkinPhotos = const [],
    this.checklist = const [],
  });

  /// Nhãn xe hiển thị: "Motorbike • Red".
  String get vehicleLabel {
    final parts =
        [vehicleTypeName, vehicleColor].where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? 'Xe khách hàng' : parts.join(' • ');
  }

  /// Các trạng thái mà washer không còn thao tác rửa nữa
  /// (đã rửa xong, đang/đã QC, huỷ...) → thuộc nhóm "Đã hoàn thành".
  static const _doneStatuses = {
    'quality_check',
    'qc',
    'qc_passed',
    'qc_failed',
    'done',
    'finished',
    'completed',
    'returned',
    'cancelled',
  };

  bool get isCompleted => _doneStatuses.contains(status.toLowerCase());

  /// Các trạng thái đơn đã giao nhưng washer chưa bấm "Bắt đầu".
  static const _waitingStatuses = {
    'assigned',
    'waiting',
    'pending',
    'created',
    'new',
  };

  /// Đang chờ washer bắt đầu.
  bool get isWaiting => _waitingStatuses.contains(status.toLowerCase());

  /// Đang rửa (đã start, chưa finish) — cho phép bấm "Hoàn thành".
  bool get isInProgress => !isWaiting && !isCompleted && status.isNotEmpty;

  factory WasherOrderModel.fromJson(Map<String, dynamic> json) {
    final rawVehicle = json['vehicleSnapshot'];
    final vehicle = rawVehicle is Map<String, dynamic>
        ? rawVehicle
        : const <String, dynamic>{};
    final rawChecklist = json['checklist'];
    final rawPhotos = json['checkinPhotos'];
    final rawMinutes = json['estimatedMinutes'];

    return WasherOrderModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      licensePlate: (vehicle['plate'] ?? '').toString(),
      vehicleTypeName: (vehicle['vehicleTypeName'] ?? '').toString(),
      vehicleColor: (vehicle['color'] ?? '').toString(),
      serviceName: (json['serviceName'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      stationName: (json['stationName'] ?? '').toString(),
      estimatedMinutes: rawMinutes is num ? rawMinutes.toInt() : 0,
      assignedWasherName: (json['assignedWasherName'] ?? '').toString(),
      startedAt: (json['startedAt'] ?? '').toString(),
      finishedAt: (json['finishedAt'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      qcPassed: json['qcPassed'] ?? false,
      qcNote: (json['qcNote'] ?? '').toString(),
      checkinPhotos: rawPhotos is List
          ? rawPhotos.map((e) => e.toString()).toList()
          : const [],
      checklist: rawChecklist is List
          ? rawChecklist
              .map((e) => ChecklistItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
