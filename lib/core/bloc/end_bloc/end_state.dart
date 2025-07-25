part of 'end_bloc.dart';

enum TripEndStatus { initial, loading, ended, error }

class EndState {
  final Map<int, TripEndStatus> tripStatuses;

  const EndState({required this.tripStatuses});

  EndState copyWith({
    Map<int, TripEndStatus>? tripStatuses,
  }) {
    return EndState(
      tripStatuses: tripStatuses ?? this.tripStatuses,
    );
  }
}
