import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics_customer/core/repo/device.dart';
import 'package:logistics_customer/core/routes/attach/vehicle.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../components/textfield.dart';
import '../../utilities/logger.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  var time = DateTime.now();
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 2000,
    formats: [
      // Only QR codes are allowed
      BarcodeFormat.qrCode,
    ],
  );

  final TextEditingController _qrController = TextEditingController();

  bool willRetake = false;

  late StreamSubscription _cameraSubscription;

  @override
  void initState() {
    super.initState();

    _cameraSubscription = cameraController.barcodes.listen((result) {
      Barcode code = result.barcodes.last;

      CustomLogger.debug(code.rawValue ?? "No Value");

      if (code.rawValue != null) {
        handleRead(code.rawValue!);
      }
    });
  }

  void handleRead(String qr) async {
    cameraController.stop();
    setState(() {
      _qrController.text = qr;
      willRetake = true;
    });
    int? deviceId = await getDeviceId(_qrController.text);
    if (deviceId == null) {
      Fluttertoast.showToast(msg: "Device Not Registered");
    }
    CustomLogger.info(deviceId!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return VehicleAttach(
            deviceId: deviceId,
            deviceQr: _qrController.text,
          );
        },
      ),
    );
    // DeviceModel data = await getMacId(_qrController.text);
    // CustomLogger.debug(data.macId);
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    //   return DetailsScreen(qr: _qrController.text, macId: data.macId);
    // }));
    // Navigator.push(context, MaterialPageRoute(builder: (context){
    //   return DetailsScreen(qr: _qrController.text, macId: "FF:F8:5F:0A:09:c2");
    // }));
  }

  // void handleRead(String qr) async {
  //   cameraController.stop();
  //
  //   setState(() {
  //     _qrController.text = qr;
  //     willRetake = true;
  //   });
  //
  //   final deviceInfoPlugin = DeviceInfoPlugin();
  //   final deviceInfo = await deviceInfoPlugin.deviceInfo;
  //   final allInfo = deviceInfo.data;
  //
  //   bool checkQr = await doesQrCodeExist(_qrController.text);
  //   if (checkQr == false) {
  //     DeviceModel device = DeviceModel(
  //         qrCode: _qrController.text,
  //         mac: "FF:F8:5F:0A:09:c2",
  //         createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(time),
  //         updatedAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(time),
  //         createdBy: widget.uid,
  //         meta: allInfo,
  //         client: widget.uid);
  //
  //     addDevice(device);
  //
  //     UserModel userdata = UserModel(
  //         uid: widget.uid,
  //         phoneNumber: widget.phoneNumber,
  //         address: widget.address,
  //         qrData: "FF:F8:5F:0A:09:c2",
  //         deviceMeta: allInfo,
  //         createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(time));
  //
  //     userAdd(userdata);
  //
  //     Navigator.push(context, MaterialPageRoute(builder: (context) {
  //       return const HomePageToBe();
  //     }));
  //   } else {
  //     Fluttertoast.showToast(msg: "Device Already Exists");
  //   }
  // }

  void retake() {
    cameraController.start();

    _qrController.clear();

    setState(() {
      willRetake = false;
    });
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: cameraController,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(painter: ScannerOverlay(scanWindowRect));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset(0, -50.sp)),
      width: 276,
      height: 276,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            scanWindow: scanWindow,
            controller: cameraController,
            errorBuilder: (context, error, child) {
              CustomLogger.error(error);

              // To be replaced
              return Container(
                alignment: Alignment.center,
                child: const Text("Something went Wrong"),
              );
            },
          ),
          _buildScanWindow(scanWindow),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "OR ENTER MANUALLY",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(controller: _qrController, label: "QR Code"),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 80.sp,
                      width: double.infinity,
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: MaterialButton(
                              height: 50.sp,
                              onPressed: () {
                                if (willRetake) {
                                  retake();
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              elevation: 0,
                              color: Colors.grey.withOpacity(0.2),
                              child: Text(
                                willRetake ? "Retake" : "Cancel",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MaterialButton(
                              height: 50.sp,
                              onPressed: () {
                                if (_qrController.text.isNotEmpty) {
                                  CustomLogger.debug(_qrController.text);
                                  handleRead(_qrController.text);
                                  //Navigator.pop(context, _qrController.text);
                                }
                              },
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              elevation: 0,
                              color: Colors.black,
                              child: const Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawDRRect(
      RRect.fromRectAndCorners(Rect.largest),
      RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)),
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcodeCorners,
    required this.barcodeSize,
    required this.boxFit,
    required this.cameraPreviewSize,
  });

  final List<Offset> barcodeCorners;
  final Size barcodeSize;
  final BoxFit boxFit;
  final Size cameraPreviewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeCorners.isEmpty ||
        barcodeSize.isEmpty ||
        cameraPreviewSize.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, cameraPreviewSize, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      ratioWidth = barcodeSize.width / adjustedSize.destination.width;
      ratioHeight = barcodeSize.height / adjustedSize.destination.height;
    } else {
      ratioWidth = cameraPreviewSize.width / adjustedSize.destination.width;
      ratioHeight = cameraPreviewSize.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [
      for (final offset in barcodeCorners)
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
    ];

    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
