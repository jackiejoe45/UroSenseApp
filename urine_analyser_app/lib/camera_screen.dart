import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'providers/settings_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false, // Disable audio
    );
    await _controller!.initialize();
    setState(() {});
  }

  Future<String> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return '';
    }

    final directory = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = path.join(directory.path, fileName);

    try {
      XFile image = await _controller!.takePicture();
      await image.saveTo(filePath);
      return filePath;
    } catch (e) {
      print("Error taking picture: $e");
      return '';
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate aspect ratio
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final xScale = _controller!.value.aspectRatio / deviceRatio;
    final scale = 1 / (xScale > 1 ? xScale : 1);

    return Scaffold(
      appBar: AppBar(title: const Text("Capture Test Strip")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current User: ${context.watch<SettingsProvider>().currentUser}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(_controller!),
                  ),
                ),
                // Guide overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.black.withOpacity(0.5),
                        width: MediaQuery.of(context).size.height * 0.3,
                      ),
                    ),
                  ),
                ),
                // Center strip guide
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final imagePath = await _takePicture();
          if (imagePath.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image saved to: $imagePath')),
            );
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
