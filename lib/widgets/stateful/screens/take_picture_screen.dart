import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final int renterId;

  const TakePictureScreen({Key? key, required this.camera, required this.renterId}) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return Column(
                children: [
                  Expanded(child: CameraPreview(_controller)),
                ],
              );
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
              onPressed: () =>
                  takePicture().then((image) => Navigator.pop(context, image)),
              child: const Icon(Icons.add_a_photo)),
        ));
  }

  Future<Uint8List?> takePicture() async{
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();
      final bytes = await image.readAsBytes();

      return bytes;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}