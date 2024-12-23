import 'dart:convert'; // For decoding JSON response
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isLoading = false; // Show loading indicator
  String? detectionResult; // For the detected label
  List<double>? probabilities; // For the probabilities of each class

  // Labels for the detected classes
  final List<String> labels = [
    "aerosol_cans",
    "aluminum_food_cans",
    "aluminum_soda_cans",
    "battery",
    "biological",
    "brown-glass",
    "cardboard_boxes",
    "cardboard_packaging",
    "clothes",
    "coffee_grounds",
    "disposable_plastic_cutlery",
    "eggshells",
    "food_waste",
    "glass_beverage_bottles",
    "glass_cosmetic_containers",
    "glass_food_jars",
    "magazines",
    "metal",
    "newspaper",
    "office_paper",
    "paper",
    "paper_cups",
    "plastic_cup_lids",
    "plastic_detergent_bottles",
    "plastic_food_containers",
    "plastic_shopping_bags",
    "plastic_soda_bottles",
    "plastic_straws",
    "plastic_trash_bags",
    "plastic_water_bottles",
    "shoes",
    "styrofoam_cups",
    "styrofoam_food_containers",
    "tea_bags",
    "trash"
  ];

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(cameras![0], ResolutionPreset.high);
        await _cameraController!.initialize();
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      // Capture the image
      final image = await _cameraController!.takePicture();

      // Send image to server for detection
      final result = await sendToServer(File(image.path));

      setState(() {
        isLoading = false; // Hide loading indicator
        detectionResult = result["prediction"];

        // Safely convert probabilities to List<double>
        if (result.containsKey("probabilities") && result["probabilities"] is List) {
          probabilities = (result["probabilities"] as List<dynamic>)
              .map((e) => e is num ? e.toDouble() : 0.0)
              .toList();
        } else {
          probabilities = [];
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        detectionResult = "Error: $e";
      });
    }
  }

  Future<Map<String, dynamic>> sendToServer(File imageFile) async {
    final url = Uri.parse("http://192.168.0.101:5000/predict"); // Your Flask API URL
    final request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        throw Exception("Error: Unable to get detection result.");
      }
    } catch (e) {
      throw Exception("Error sending image to server: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Scan",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),
          // Detection Results Overlay
          if (detectionResult != null)
            Positioned(
              top: 20,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Detection: $detectionResult",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          // Probabilities Overlay
          if (probabilities != null)
            Positioned(
              bottom: 100,
              child: Container(
                color: Colors.white.withOpacity(0.9),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Probabilities:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...probabilities!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final probability = entry.value;
                      return Text(
                        "${labels[index]}: ${(probability * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(fontSize: 14),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          // Loading Indicator
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
          // Capture Button
          Positioned(
            bottom: 30,
            child: IconButton(
              icon: const Icon(Icons.camera, size: 60, color: Colors.white),
              onPressed: captureAndDetect,
            ),
          ),
        ],
      ),
    );
  }
}
