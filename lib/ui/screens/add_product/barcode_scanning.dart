import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class AddProductBarcodeScan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddProductBarcodeScanState();
  }
}

class _AddProductBarcodeScanState extends State<AddProductBarcodeScan>
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

  bool _processing = false;

  bool _found = false;

  void _processImage(CameraImage image) async {
    if (!_processing && !_found) {
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
        _found = true;
        Navigator.pop(context, barcodes.first.barcodeUnknown.rawValue);
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
      _controller.startImageStream((image) => _processImage(image));
      setState(() => _initialised = true);
    });
  }

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: _cameras == null
                ? CircularProgressIndicator()
                : CameraPreview(_controller),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() async {
    _barcodeScanner.close();
    await _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }
}
