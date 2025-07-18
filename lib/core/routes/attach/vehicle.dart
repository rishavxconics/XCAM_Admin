import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logistics_customer/core/components/custombuttons.dart';
import 'package:logistics_customer/core/repo/vehicle.dart';
import 'package:logistics_customer/core/routes/home.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/trip.dart';
import '../../models/vehicle.dart';
import '../../repo/trip.dart';
import '../../utilities/logger.dart';

class VehicleAttach extends StatefulWidget {
  final int deviceId;
  final String deviceQr;

  const VehicleAttach({
    super.key,
    required this.deviceId,
    required this.deviceQr,
  });

  @override
  State<VehicleAttach> createState() => _VehicleAttachState();
}

class _VehicleAttachState extends State<VehicleAttach> {
  List<VehicleModel> vehicles = [];
  VehicleModel? _selectedVehicle;
  bool isLoading = true;
  bool isCreatingTrip = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLocationServices();
    getVehicle();
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

  void getVehicle() async {
    final vehicleList = await fetchVehicle();
    setState(() {
      vehicles = vehicleList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "XCAM Create",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Device QR:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(widget.deviceQr, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Select Vehicle:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<VehicleModel>(
                    value: _selectedVehicle,
                    items: vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle,
                        child: Text(vehicle.vehicleNumber),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      setState(() {
                        _selectedVehicle = selected;
                      });
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: isCreatingTrip,
                        child: CustomButton(
                          label: "Start Trip",
                          onPressed: () async {
                            if (_selectedVehicle == null) {
                              Fluttertoast.showToast(
                                msg: "Please select a vehicle",
                              );
                              return;
                            }
                            setState(() {
                              isCreatingTrip = true;
                            });
                            Position position = await _determinePosition();

                            final trip = TripModel(
                              startedAt: DateTime.now(),
                              deviceId: widget.deviceId,
                              vehicleId: _selectedVehicle!.id,
                              status: "0",
                              attLat: position.latitude,
                              attLang: position.longitude,
                            );

                            try {
                              await createTrip(trip, _selectedVehicle!.vehicleNumber);
                                Fluttertoast.showToast(
                                  msg: "Trip Created successfully!",
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Home();
                                    },
                                  ),
                                );
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: "Failed to start trip",
                              );
                            } finally {
                              setState(() {
                                isCreatingTrip = false;
                              });
                            }
                          },
                        ),
                      ),
                      if (isCreatingTrip)
                        const Positioned(
                          left: 0,
                          right: 0,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
