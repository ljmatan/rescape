import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rescape/data/current_order.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/new_order.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/ui/screens/scanner/bloc/last_scanned_controller.dart';
import 'current_order/current_order_button.dart';
import 'new_order_elements/add_item_dialog.dart';
import 'new_order_elements/current_order_button.dart';
import 'back_button.dart';
import 'bottom_section/bottom_section_display.dart';
import 'camera_title.dart';
import 'view_blocking.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:vibration/vibration.dart';

class CameraScreen extends StatefulWidget {
  final LocationModel location;

  CameraScreen({this.location});

  @override
  State<StatefulWidget> createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras;

  CameraController _controller;

  bool _initialised = false;

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) allBytes.putUint8List(plane.bytes);
    return allBytes.done().buffer.asUint8List();
  }

  final BarcodeScanner _barcodeScanner =
      GoogleMlKit.instance.barcodeScanner([Barcode.FORMAT_EAN_13]);

  bool _processingEnabled = true;
  bool _processingOverriden = false;
  void _scanning(bool value, [bool overriden = false]) {
    _processingEnabled = value;
    _processingOverriden = overriden;
  }

  bool _processing = false;

  void _processImage(CameraImage image) async {
    if (!_processing) {
      _processing = true;

      final inputImage = InputImage.fromBytes(
        bytes: _concatenatePlanes(image.planes),
        inputImageData: InputImageData(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          imageRotation: InputImageRotation.Rotation_0deg,
        ),
      );

      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes != null && barcodes.isNotEmpty) {
        final String barcode = barcodes.first.barcodeUnknown.rawValue;
        final ProductModel scannedProduct = ProductList.instance.firstWhere(
            (e) =>
                e.barcode.length == 7 && barcode.startsWith(e.barcode) ||
                e.barcode == barcode,
            orElse: () => null);

        if (scannedProduct != null) {
          _scanning(false);

          if (scannedProduct.measureType == Measure.kg)
            scannedProduct.barcode = barcode;

          if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 100);

          await showDialog(
            context: context,
            barrierColor: Colors.white70,
            builder: (context) => AddItemDialog(product: scannedProduct),
          );

          scannedProduct.barcode = scannedProduct.barcode.substring(0, 7);

          Future.delayed(const Duration(seconds: 3), () => _scanning(true));
        } else
          print('Code $barcode not registered');
      } else
        print('No barcodes found');

      _processing = false;
    }
  }

  void _setController() {
    if (_initialised) setState(() => _initialised = false);
    _controller = CameraController(
      _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      ),
      ResolutionPreset.max,
      enableAudio: false,
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.startImageStream((image) {
        if (_processingEnabled && !_processingOverriden) _processImage(image);
      });
      setState(() => _initialised = true);
    });
  }

  @override
  void initState() {
    super.initState();
    LastScannedController.init();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _cameras = await availableCameras();
      _setController();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive)
      _controller?.dispose();
    else if (state == AppLifecycleState.resumed) if (_controller != null)
      _setController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _initialised
          ? Stack(
              children: [
                CameraPreview(_controller),
                ViewBlocking(),
                ExitCameraButton(),
                CameraTitle(),
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).padding.top + 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CurrentOrderButton(
                        scanning: _scanning,
                        location: widget.location,
                      ),
                      if (CurrentOrder.instance != null)
                        OrderedItemsButton(
                          scanning: _scanning,
                          location: CurrentOrder.instance.location,
                          orderItems: CurrentOrder.instance.items,
                        ),
                    ],
                  ),
                ),
                BottomSection(
                  scanning: _scanning,
                  setFlash: _controller.setFlashMode,
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    _controller?.dispose();
    LastScannedController.dispose();
    CurrentOrder.setInstance(null);
    NewOrder.clear();
    super.dispose();
  }
}
