import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logistics_customer/core/bloc/auth/auth_bloc.dart';
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
    trips.sort((a, b) => b.startedAt.compareTo(a.startedAt));
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
                ? const Center(child: Text("No Current Trips"))
                : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dataTableTheme: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.all(
                              Colors.grey[300],
                            ),
                          ),
                        ),
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                "Sln No",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "Vehicle",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Device",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Start Time",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Actions",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: trips.map((trip) {
                            return DataRow(
                              cells: [
                                DataCell(Text(trip.sequenceNumber)),
                                DataCell(Text(trip.vehicleNumber)),
                                DataCell(Text(trip.deviceQr)),
                                DataCell(
                                  Text(
                                    trip.startedAt.toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: trip.detLang == null
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    onPressed: trip.detLang == null
                                        ? () async {
                                            await checkLocationServices();
                                            Position position =
                                                await _determinePosition();
                                            final updateModel = TripUpdateModel(
                                              status: "1",
                                              detLat: position.latitude,
                                              detLang: position.longitude,
                                              endedAt: DateTime.now(),
                                            );
                                            await updateTrip(
                                              updateModel,
                                              trip.id,
                                            );
                                            getAllTrips();
                                          }
                                        : null,
                                    child: Text(
                                      "End Trip",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
