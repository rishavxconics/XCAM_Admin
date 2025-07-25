library end_bloc;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics_customer/core/models/error.dart';
import 'package:logistics_customer/core/models/trip.dart';
import 'package:logistics_customer/core/utilities/logger.dart';

import '../../repo/trip.dart';

part 'end_state.dart';

part 'end_event.dart';

class EndBloc extends Bloc<EndEvent, EndState> {
  EndBloc() : super(const EndState(tripStatuses: {})) {
    on<EndTripEvent>(_onEndTrip);
  }

  FutureOr<void> _onEndTrip(EndTripEvent event, Emitter<EndState> emit) async {
    final updated = Map<int, TripEndStatus>.from(state.tripStatuses);
    updated[event.tripId] = TripEndStatus.loading;
    emit(state.copyWith(tripStatuses: updated));

    try {
      await updateTrip(event.trip, event.tripId);
      updated[event.tripId] = TripEndStatus.ended;
      emit(state.copyWith(tripStatuses: updated));
    } catch (e) {
      CustomLogger.error(e);
      updated[event.tripId] = TripEndStatus.error;
      emit(state.copyWith(tripStatuses: updated));
    }
  }
}
