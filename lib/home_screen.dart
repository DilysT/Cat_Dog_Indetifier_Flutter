import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier.dart';  // Gọi model nhận diện

class HomeScreen extends StatefulWidget {
  final Classifier classifier;

  const HomeScreen({super.key, required this.classifier});

  @override
  _HomeScreenState createState() => _HomeScreenState();
} 

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _result = "Please choose one";
  bool _isProcessing = false;

  // Hàm chọn ảnh từ thư viện hoặc camera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "Processing...";
        _isProcessing = true;
      });
      await _classifyImage(_image!);
    }
  }

  // Hàm nhận diện ảnh bằng model
  Future<void> _classifyImage(File image) async {
    String label = await widget.classifier.classifyImage(image);
    setState(() {
      _result = "Result: $label";
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🐶🐱 Dogs and cats identifier"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_image!, height: 250, fit: BoxFit.cover),
                ),
              )
                  : const Text("📷 Choose a picture", style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(Icons.photo, "Your gallery", () => _pickImage(ImageSource.gallery)),
                  const SizedBox(width: 15),
                  _buildActionButton(Icons.camera_alt, "Capture image", () => _pickImage(ImageSource.camera)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      icon: Icon(icon, color: Colors.blueAccent),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      onPressed: onTap,
    );
  }
}