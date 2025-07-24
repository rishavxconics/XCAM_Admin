library upload_bloc;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics_customer/core/models/error.dart';
import 'package:logistics_customer/core/models/trip.dart';
import 'package:logistics_customer/core/repo/trip.dart';
import 'package:logistics_customer/core/utilities/localStorage.dart';
import 'package:logistics_customer/core/utilities/logger.dart';

part 'upload_event.dart';
part 'upload_state.dart';
int attempts = 0;

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc(): super(UploadInitialState()){
    on<UploadBackLogEvent>(_upload);
  }

  Future<void> _upload(UploadBackLogEvent event, Emitter<UploadState> emit) async{
    try{
      emit(UploadLoadingState());
      String token = await SecureLocalStorage.getValue("token");
      bool check = await updateTripStatus(event.data,event.tripId, token);
      if(check == true){
          emit(UploadLoadedState());
      }
    }catch(e){
      CustomLogger.error(e);
      emit(UploadErrorState(errorModel: ErrorModel(message: "Error Uploading Backlog", e: e)));
    }
  }
}