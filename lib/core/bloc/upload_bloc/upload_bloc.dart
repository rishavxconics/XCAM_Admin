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

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  Timer? _statusRefreshTimer;
  UploadBloc(): super(UploadInitialState()){
    on<UploadBackLogEvent>(_upload);
    on<UploadCheckCompletedEvent>((event, emit) {
      emit(UploadLoadedState());
    });
  }

  Future<void> _upload(UploadBackLogEvent event, Emitter<UploadState> emit) async{
    try{
      emit(UploadLoadingState());
      String token = await SecureLocalStorage.getValue("token");
      bool check = await updateTripStatus(event.data,event.tripId, token);
      if(check == true){
        _statusRefreshTimer?.cancel();
        _statusRefreshTimer = Timer.periodic(Duration(seconds: 10), (_) async{
          List<TripViewModel> trip = await getTrips();
          if(trip.isNotEmpty && trip[0].status=="2"){
            add(UploadCheckCompletedEvent());
            _statusRefreshTimer?.cancel();
          }
        });
      }
    }catch(e){
      CustomLogger.error(e);
      emit(UploadErrorState(errorModel: ErrorModel(message: "Error Uploading Backlog", e: e)));
    }
  }
}