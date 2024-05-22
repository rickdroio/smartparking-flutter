import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class CameraQRCode extends StatefulWidget {
  @override
  _CameraQRCodeState createState() => _CameraQRCodeState();
}

enum DetectionState {empty, invalid, detected, notSupported}

/// Scan a device QR code and validate its contents
class _CameraQRCodeState extends State<CameraQRCode> {
  /// MLKit vision detector for QR codes
  final BarcodeDetector _detector = FirebaseVision.instance.barcodeDetector(
    BarcodeDetectorOptions(
      barcodeFormats: BarcodeFormat.qrCode
    )
  );

  CameraController _controller;
  DetectionState _currentState = DetectionState.empty;
  bool _scanInProgess = false;
  bool _barcodeDetected = false;

  /// Callback to handle each camera frame
  void _handleCameraImage(CameraImage image) async {
    // Drop the frame if we are still scanning
    if (_scanInProgess || _barcodeDetected) return;

    _scanInProgess = true;

    // Collect all planes into a single buffer
    final WriteBuffer allBytesBuffer = WriteBuffer();
    image.planes.forEach((Plane plane) => allBytesBuffer.putUint8List(plane.bytes));
    final Uint8List allBytes = allBytesBuffer.done().buffer.asUint8List();

    // Convert the image buffer into a Firebase detector frame
    FirebaseVisionImage firebaseImage = FirebaseVisionImage.fromBytes(allBytes,
      FirebaseVisionImageMetadata(
        rawFormat: image.format.raw,
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: ImageRotation.rotation90,
        planeData: image.planes.map((plane) => FirebaseVisionImagePlaneMetadata(
          height: plane.height,
          width: plane.width,
          bytesPerRow: plane.bytesPerRow,
        )).toList(),
      ),
    );

    try {
      // Run detection and check for the proper QR code
      final List<Barcode> barcodes = await _detector.detectInImage(firebaseImage);
      if (barcodes.isEmpty) {
        _reportDetectionState(DetectionState.empty);
      } else {
        final String device = await _handleBarcodeResult(barcodes[0]);
        _barcodeDetected = true;
        _reportDetectionState(DetectionState.detected);
        print('DETECTED = $device');
        Navigator.of(context).pop(device);
      }     
    } 
    on PlatformException catch (error) {
      print('PlatformException ${error.code}');
      //PlatformException(textRecognizerError, Waiting for the text recognition model to be downloaded. Please wait., null)
      _reportDetectionState(DetectionState.notSupported);
    }       
    catch (error) {
      print(error);
      _reportDetectionState(DetectionState.invalid);
    } 
    finally {
      _scanInProgess = false;
    }
  }

  /// Utility to update UI with scanner state
  void _reportDetectionState(DetectionState state) {
    if (mounted) {
      setState(() {
        _currentState = state;
      });
    }
  }

  /// Validate a QR code as device data
  Future<String> _handleBarcodeResult(Barcode barcode) async {
    // Check for valid QR code data type
    if (barcode.valueType != BarcodeValueType.text) {
      throw("Invalid QR code type");
    }
    
    return barcode.rawValue;
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      // Choose the back camera, or first available
      CameraDescription selected = cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first);

      _controller = CameraController(selected, ResolutionPreset.low, enableAudio: false);
      _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }

        _controller.startImageStream(_handleCameraImage);
        // Rebuild UI once camera is fully initialized
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Leitor'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Posicione a camera sobre o código de barras', textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.title),
              ),
              Expanded(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller)
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: _detectionStateWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detectionStateWidget() {
    switch (_currentState) {
      case DetectionState.notSupported:
        return Text('Reconhecimento não disponível nesse dispositivo', textAlign: TextAlign.center);       
      case DetectionState.detected:
        return Text('QR Code detectado', textAlign: TextAlign.center);
      case DetectionState.invalid:
        return Text('QR code não detectado', textAlign: TextAlign.center);
      case DetectionState.empty:
      default:
        return Text('', textAlign: TextAlign.center);
    }
  }
}