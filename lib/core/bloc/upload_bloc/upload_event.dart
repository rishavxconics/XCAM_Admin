part of 'upload_bloc.dart';

abstract class UploadEvent {}

class UploadBackLogEvent extends UploadEvent {
  final TripUpdateModel data;
  final DateTime? startTime;
  final String? device;
  final int tripId;

  UploadBackLogEvent({
    required this.tripId,
    this.startTime,
    this.device,
    required this.data,
  });
}
