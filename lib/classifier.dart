import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  Interpreter? _interpreter;
  late List<String> _labels;
  bool _isModelLoaded = false;

  /// Constructor khởi tạo model
  Classifier() {
    init();
  }

  /// Khởi tạo model & labels (chờ tải xong)
  Future<void> init() async {
    await _loadModel();
    _isModelLoaded = true;
  }

  /// Tải mô hình và nhãn
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/tflite_model.tflite");

      final labelData = await rootBundle.loadString("assets/labels.txt");
      _labels = labelData.split("\n").where((element) => element.isNotEmpty).toList();

      print("✅ Model và nhãn đã tải xong!");
    } catch (e) {
      print("❌ Lỗi khi tải mô hình hoặc nhãn: $e");
    }
  }

  /// Phân loại ảnh và trả về nhãn
  Future<String> classifyImage(File image) async {
    if (!_isModelLoaded || _interpreter == null) {
      return "❌ Model chưa sẵn sàng!";
    }

    // Tiền xử lý ảnh
    var input = await _preprocessImage(image);

    // Reset output để tránh lỗi từ dữ liệu cũ
    var output = List.generate(1, (index) => List.filled(_labels.length, 0.0));

    // Chạy mô hình
    _interpreter!.run(input, output);

    // Lấy index có giá trị cao nhất
    int predictedIndex = output[0].indexWhere((value) => value == output[0].reduce((a, b) => a > b ? a : b));

    // Kiểm tra nếu index nằm trong phạm vi hợp lệ
    if (predictedIndex < 0 || predictedIndex >= _labels.length) {
      return "❌ Không nhận diện được đối tượng!";
    }

    return _labels[predictedIndex];
  }

  /// Tiền xử lý ảnh: Xoay ảnh đúng hướng, Resize, chuẩn hóa và chuyển sang tensor 1x224x224x3
  Future<List<List<List<List<double>>>>> _preprocessImage(File file) async {
    var image = img.decodeImage(await file.readAsBytes());

    if (image == null) {
      throw Exception("❌ Không thể đọc ảnh");
    }

    // Điều chỉnh xoay ảnh về đúng hướng (nếu có metadata EXIF)
    var fixedImage = img.bakeOrientation(image);

    // Resize ảnh về 224x224
    var resizedImage = img.copyResize(fixedImage, width: 224, height: 224);

    // Chuyển đổi ảnh thành tensor 1x224x224x3
    List<List<List<List<double>>>> input = List.generate(
      1,
          (i) => List.generate(
        224,
            (j) => List.generate(
          224,
              (k) {
            var pixel = resizedImage.getPixel(j, k);
            return [
              pixel.r / 255.0, // Chuẩn hóa kênh Red
              pixel.g / 255.0, // Chuẩn hóa kênh Green
              pixel.b / 255.0  // Chuẩn hóa kênh Blue
            ];
          },
        ),
      ),
    );

    return input;
  }
}
