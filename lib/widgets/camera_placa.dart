import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import '../service/entrada_service.dart';

enum DetectionState {empty, invalid, detected, notSupported}

class CameraPlaca extends StatefulWidget {
  CameraPlaca({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CameraPlacaState createState() => _CameraPlacaState();
}


class _CameraPlacaState extends State<CameraPlaca> {
    
  CameraController _controller;
  DetectionState _currentState = DetectionState.empty;
  bool _scanInProgess = false;
  String _detectedText = '';

  String _placaDetectada = '';

  /// Callback to handle each camera frame
  void _handleCameraImage(CameraImage image) async {

    // Drop the frame if we are still scanning
    if (_scanInProgess ) return;
    //if (_scanInProgess || _placaDetected) return;

    _scanInProgess = true;

    // Collect all planes into a single buffer
    final WriteBuffer allBytesBuffer = WriteBuffer();
    image.planes.forEach((Plane plane) => allBytesBuffer.putUint8List(plane.bytes));
    final Uint8List allBytes = allBytesBuffer.done().buffer.asUint8List();    

    // Convert the image buffer into a Firebase detector frame
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromBytes(allBytes,
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

    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

    try {
      // Run detection and check
      final VisionText visionText = await textRecognizer.processImage(visionImage);
      print('TEXTO VISION = ${visionText.text}'); 

      String texto = _removeSpecialChars(visionText.text);

      if (texto.isEmpty) {
        _reportDetectionState(DetectionState.empty);
      }
      else if (EntradaService.validarPlaca(texto)) {
        String placa = EntradaService.getPlaca(texto);
        print('placa ====== $placa');
        print('placa OLD ==== $_placaDetectada');

        //+ precisao, comparar 2 amostras se o texto for o mesmo
        if (placa == _placaDetectada) {
          print('PLACA DETECTADO = $placa');
          _reportDetectionState(DetectionState.detected);
          Navigator.of(context).pop(placa);
        }
        else {
          _placaDetectada = placa;
        }       
      }
      else {
        _reportDetectionState(DetectionState.invalid);
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

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);  


    availableCameras().then((cameras) {

      // Choose the back camera, or first available
      CameraDescription selected = cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first
      );

      _controller = CameraController(selected, ResolutionPreset.low, enableAudio: false); //ResolutionPreset.low = lower enddevices
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
        title: const Text('Identificar Placa'),
      ),
      body: _renderCameraPreview()
    );     

    /*
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Scan device QR code',
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
    */
  }

  Widget _detectionStateWidget() {
    switch (_currentState) {
      case DetectionState.notSupported:
        return Text('Reconhecimento de placa não disponível nesse dispositivo', textAlign: TextAlign.center, style: TextStyle(color: Colors.white));      
      case DetectionState.detected:
        //return Icon(Icons.check_circle, color: Colors.green, size: 48.0);
        //return Text('Placa detectada !! ($_placaDetectada)', style: TextStyle(color: Colors.white));
        return Text('Placa detectada!!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white));
      case DetectionState.invalid:
        //return Text('Placa não detectada ($_placaDetectada)', style: TextStyle(color: Colors.white));
        return Text('Placa não detectada', textAlign: TextAlign.center, style: TextStyle(color: Colors.white));
        //return Icon(Icons.cancel, color: Colors.red, size: 48.0);
      case DetectionState.empty:
      default:
        return Text('Posicione a câmera em frente a placa', textAlign: TextAlign.center, style: TextStyle(color: Colors.white));
    }
  }

  Widget _renderCameraPreview() {
    return Container(
      color: Colors.black,
      height: double.maxFinite,
      child: Stack(children: <Widget>[
        AspectRatio(aspectRatio: _controller.value.aspectRatio, child: CameraPreview(_controller)),
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 0.3,
              child: Container(decoration: 
                BoxDecoration(border: Border(
                  left: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ))
              ),
          )
        ),


        Positioned(
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 80),
              child: _detectionStateWidget()              
            )
          ),
        ),

        /*
        Positioned(
          child: Align(
            alignment: FractionalOffset.bottomRight,
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: FlatButton(child: Icon(MdiIcons.cameraRetake, size: 30, color: Colors.white),
                //onPressed: () => toggleCameraSelected()
              )
            )
          ),
        ) */              
      ])
    );
  }

  String _removeSpecialChars(String text) {
    return text.replaceAll(new RegExp(r'[\s-]'), '').toUpperCase(); //remove os espaços
  }    

}