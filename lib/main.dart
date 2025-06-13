import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
 _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Image picker instance for selecting images from gallery
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  Interpreter? _interpreter;
  String _result = '';
  String _errorMessage = '';

  // List of waste categories that the model can classify
  final List<String> _classNames = ['Battery', 'Keyboard', 'Microwave', 'Mobile', 'Mouse', 'PCB', 
                'Player', 'Printer', 'Television', 'Washing Machine', 
                'cardboard', 'glass', 'metal', 'organic', 'paper', 'plastic', 'trash'];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TFLite model from assets
  _loadModel() async {
    try {
      const modelPath = 'assets/models/WasteClassification_model.tflite';
      _interpreter = await Interpreter.fromAsset(modelPath);
      setState(() {
        _errorMessage = '';
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Error loading model: $e';
      });
    }
  }

  // Pick an image from the gallery
  _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  // Map of waste types to their corresponding recycling bins
  String _getWasteBin(String wasteType) {
    const wasteBinMap = {
      'battery': 'Electronic Waste Bin',
      'mobile': 'Electronic Waste Bin',
      'pcb': 'Electronic Waste Bin',
      'player': 'Electronic Waste Bin',
      'printer': 'Electronic Waste Bin',
      'mouse': 'Electronic Waste Bin',
      'keyboard': 'Electronic Waste Bin',
      'television': 'Electronic Waste Bin',
      'washing machine': 'Electronic Waste Bin',
      'cardboard': 'Paper/Cardboard Bin',
      'paper': 'Paper/Cardboard Bin',
      'glass': 'Glass Bin',
      'metal': 'Plastic/Metal Bin',
      'plastic': 'Plastic/Metal Bin',
      'organic': 'Organic Waste Bin',
      'trash': 'General Waste Bin',
    };

    return wasteBinMap[wasteType.toLowerCase()] ?? 'Unknown Waste Type';
  }

  // Classify the selected image using the TFLite model
  _classify() async {
    if (_imagePath == null || _interpreter == null) return;

    // Load and preprocess the image
    final imageFile = File(_imagePath!);
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    image = img.copyResize(image!, width: 224, height: 224);

    // Prepare input tensor
    var input = List.generate(1, (i) =>
      List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = image!.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    ).cast<List<List<List<double>>>>();

    // Prepare output tensor
    var output = List.generate(1, (_) => List.filled(17, 0.0));

    // Run inference
    _interpreter!.run(input, output);

    // Get the prediction results
    final predictions = output[0];
    final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
    final wasteType = _classNames[maxIndex];
    final wasteBin = _getWasteBin(wasteType);

    // Update the UI with results
    setState(() {
      _result = 'Waste Type: $wasteType\nRecycling Bin: $wasteBin\nConfidence: ${(predictions[maxIndex] * 100).toStringAsFixed(2)}%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waste Classification')),
      body: Center(
        child: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            if (_imagePath != null) ...[
              Image.file(File(_imagePath!), height: 200 , width: 200),
              ElevatedButton(
                onPressed: _classify,
                child: const Text('Classify'),
              ),
              Text(_result),
            ],
          ],
        ),
      ),
    );
  }
}