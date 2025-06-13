# TFLite Demo

This project demonstrates the implementation of a CNN (Convolutional Neural Network) model on Android devices using Flutter and TensorFlow Lite. The application performs real-time waste classification by processing images through a pre-trained deep learning model.

## Technical Implementation

- Built with Flutter for cross-platform mobile development
- Uses TensorFlow Lite for efficient model inference on mobile devices
- Implements a CNN model for image classification
- Processes input images to 224x224 resolution
- Supports 17 different waste categories
- Optimized for mobile performance

## Features

- Real-time waste classification using CNN
- Classifies 17 different types of waste
- Suggests appropriate recycling bins
- Image selection from gallery
- Confidence score display

## Categories

- Electronic: Battery, Keyboard, Mobile, Mouse, PCB, Player, Printer, TV, Washing Machine
- Recyclable: Cardboard, Glass, Metal, Paper, Plastic
- Other: Organic, Trash

## Setup

1. Clone the repository
2. Run `flutter pub get`
3. Place your model in `assets/models/WasteClassification_model.tflite`
4. Run the app

## Dependencies

- tflite_flutter: ^0.11.0
- image_picker: ^1.1.2
- image: ^4.1.3
