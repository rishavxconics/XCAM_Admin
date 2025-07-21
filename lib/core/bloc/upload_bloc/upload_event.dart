part of 'upload_bloc.dart';

abstract class UploadEvent {}

class UploadBackLogEvent extends UploadEvent {
  final TripUpdateModel data;
  final int tripId;

  UploadBackLogEvent({required this.tripId, required this.data});
}

class UploadCheckCompletedEvent extends UploadEvent {}
