part of 'end_bloc.dart';

abstract class EndEvent {}

class EndTripEvent extends EndEvent {
  final int tripId;
  final TripUpdateModel trip;

  EndTripEvent({required this.trip, required this.tripId});
}
