class TripModel {
  final DateTime startedAt;
  final int deviceId;
  final int vehicleId;
  final String status;
  final double attLat;
  final double attLang;
  final int cameraStatus;

  TripModel({
    required this.startedAt,
    required this.deviceId,
    required this.vehicleId,
    required this.status,
    required this.attLat,
    required this.attLang,
    required this.cameraStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      "started_at": startedAt.toIso8601String(),
      "device_id": deviceId,
      "vehicle_id": vehicleId,
      "status": status,
      "att_lat": attLat,
      "att_lang": attLang,
      "camera_status": cameraStatus,
    };
  }
}

class TripViewModel {
  final int id;
  final String sequenceNumber;
  final String? status;
  final DateTime startedAt;
  final double attLat;
  final double attLang;
  final double? detLat;
  final double? detLang;
  final String deviceQr;
  final String vehicleNumber;

  TripViewModel({
    required this.id,
    required this.sequenceNumber,
    required this.status,
    required this.startedAt,
    required this.attLat,
    required this.attLang,
    required this.detLang,
    required this.detLat,
    required this.deviceQr,
    required this.vehicleNumber,
  });

  factory TripViewModel.fromJson(Map<String, dynamic> json) {
    return TripViewModel(
      id: json['id'],
      sequenceNumber: json['seq_number'],
      status: json['status'],
      startedAt: DateTime.parse(json['started_at']),
      attLat: (json['att_lat'] as num).toDouble(),
      attLang: (json['att_lang'] as num).toDouble(),
      detLat: json['det_lat'] != null
          ? (json['det_lat'] as num).toDouble()
          : null,
      detLang: json['det_lang'] != null
          ? (json['det_lang'] as num).toDouble()
          : null,
      deviceQr: json['device']['qr'],
      vehicleNumber: json['vehicle']['vehicle_number'],
    );
  }
}

class TripUpdateModel {
  final int cameraStatus;
  final String status;
  final double detLat;
  final double detLang;
  final DateTime endedAt;

  TripUpdateModel({
    required this.cameraStatus,
    required this.status,
    required this.detLat,
    required this.detLang,
    required this.endedAt,
  });

  Map<String, dynamic> toFormData() {
    return {
      "camera_status": cameraStatus,
      "status": status,
      "det_lat": detLat,
      "det_lang": detLang,
      "ended_at": endedAt.toIso8601String(),
    };
  }
}
