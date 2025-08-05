import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:logistics_customer/core/bloc/end_bloc/end_bloc.dart';
import 'package:logistics_customer/core/bloc/upload_bloc/upload_bloc.dart';
import 'package:logistics_customer/core/components/custombuttons.dart';
import 'package:logistics_customer/core/models/trip.dart';
import 'package:logistics_customer/core/repo/trip.dart';
import 'package:logistics_customer/core/routes/attach/qrScanner.dart';
import 'package:logistics_customer/core/routes/login/login.dart';
import 'package:logistics_customer/core/utilities/localStorage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utilities/logger.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<TripViewModel> trips = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTrips();
  }

  void getAllTrips() async {
    trips = await getTrips();
    setState(() {});
  }

  Future<void> checkLocationServices() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      Fluttertoast.showToast(msg: "Please turn on location services.");
      await Geolocator.openLocationSettings();
    } else {
      await requestLocationPermission();
    }
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    CustomLogger.debug(status);
    if (status.isDenied || status.isPermanentlyDenied) {
      if (await Permission.location.request().isGranted) {
        Fluttertoast.showToast(msg: "Location permission granted.");
      } else {
        Fluttertoast.showToast(
          msg: "Location permission is required to use this app.",
        );
      }
    } else if (status.isGranted) {
      Fluttertoast.showToast(msg: "Location access is enabled.");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 30),
              Text(
                "XCAM Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              SecureLocalStorage.deleteValue("token");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Login();
                  },
                ),
              );
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 200,
              child: CustomButton(
                label: "Create New Trip",
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return QrScanner();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: trips.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sln No: ${trip.sequenceNumber}",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text("Vehicle: ${trip.vehicleNumber}"),
                                  Text("Device: ${trip.deviceQr}"),
                                  Text("Start Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(trip.startedAt)}"),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  BlocBuilder<EndBloc, EndState>(
                                    builder: (context, state) {
                                      final status =
                                          state.tripStatuses[trip.id] ??
                                              TripEndStatus.initial;
                                      final isLoading =
                                          status == TripEndStatus.loading;
                                      final isEnded =
                                          status == TripEndStatus.ended;

                                      if (isLoading) {
                                        return const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        );
                                      }

                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isEnded
                                              ? Colors.grey
                                              : Colors.red,
                                        ),
                                        onPressed:
                                        (trip.detLang == null && !isEnded)
                                            ? () async {
                                          await checkLocationServices();
                                          Position position =
                                          await _determinePosition();
                                          final updateModel =
                                          TripUpdateModel(
                                            cameraStatus: 1,
                                            status: "0",
                                            detLat: position.latitude,
                                            detLang:
                                            position.longitude,
                                            endedAt: DateTime.now(),
                                          );
                                          context.read<EndBloc>().add(
                                            EndTripEvent(
                                              trip: updateModel,
                                              tripId: trip.id,
                                            ),
                                          );
                                        }
                                            : null,
                                        child: Text(
                                          isEnded ? "Ended" : "End Trip",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  BlocConsumer<UploadBloc, UploadState>(
                                    listener: (context, state) {
                                      if (state is UploadLoadingState) {
                                        context.read<UploadBloc>().uploadingTripId = trip.id;
                                      } else if (state is UploadLoadedState) {
                                        if (context.read<UploadBloc>().uploadingTripId == trip.id) {
                                          Fluttertoast.showToast(
                                            msg: "Uploading Backup",
                                          );
                                          context.read<UploadBloc>().uploadingTripId = 0;
                                        }
                                      } else if (state is UploadErrorState) {
                                        if (context.read<UploadBloc>().uploadingTripId == trip.id) {
                                          Fluttertoast.showToast(msg: "Upload failed: ${state.errorModel.message}",);
                                          context.read<UploadBloc>().uploadingTripId = 0;
                                        }
                                      }
                                    },
                                    builder: (context, state) {
                                      return IconButton(
                                        icon: const Icon(
                                          Icons.file_upload_outlined,
                                        ),
                                        onPressed: () {
                                          Fluttertoast.showToast(
                                            msg: "Uploading Backup",
                                          );
                                          final updateModel = TripUpdateModel(
                                            cameraStatus: trip.cameraStatus,
                                            status: "1",
                                          );
                                          context.read<UploadBloc>().add(
                                            UploadBackLogEvent(
                                              device: trip.deviceQr,
                                              startTime: trip.startedAt,
                                              tripId: trip.id,
                                              data: updateModel,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
