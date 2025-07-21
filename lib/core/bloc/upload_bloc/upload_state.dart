part of 'upload_bloc.dart';

abstract class UploadState {}

class UploadInitialState extends UploadState {}

class UploadLoadingState extends UploadState {}

class UploadLoadedState extends UploadState {}

class UploadErrorState extends UploadState {
  final ErrorModel errorModel;

  UploadErrorState({required this.errorModel});
}
