import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' show join;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cartpress_smartsheet/theme_provider.dart';

class SheetSizeScreen extends StatefulWidget {
  final Map? existingData;
  final dynamic existingDataKey; // <-- استقبل الـ key وليس الـ index

  const SheetSizeScreen({super.key, this.existingData, this.existingDataKey});

  @override
  _SheetSizeScreenState createState() => _SheetSizeScreenState();
}

class _SheetSizeScreenState extends State<SheetSizeScreen> {
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productCodeController = TextEditingController();

  final Box savedSheetSizesBox = Hive.box('savedSheetSizes');

  CameraController? _cameraController;
  bool _isCameraReady = false;
  List<File> _capturedImages = [];
  bool _isProcessing = false;

  bool isOverFlap = false;
  bool isFlap = true;
  bool isOneFlap = false;
  bool isTwoFlap = true;
  bool addTwoMm = false;
  bool isFullSize = true;
  bool isQuarterSize = false;
  bool isQuarterWidth = true;
  String result = "";
  String sheetLengthResult = "";
  String sheetWidthResult = "";
  String productionWidth1 = "";
  String productionWidth2 = "";
  String productionHeight = "";

  Future<ResolutionPreset> getCameraResolution() async {
    final prefs = await SharedPreferences.getInstance();
    final String savedQuality = prefs.getString('cameraQuality') ?? 'medium';

    switch (savedQuality) {
      case 'low':
        return ResolutionPreset.low;
      case 'high':
        return ResolutionPreset.high;
      case 'medium':
      default:
        return ResolutionPreset.medium;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      _loadExistingData(data);
      if (data.containsKey('imagePaths') && data['imagePaths'] is List) {
        final List<dynamic> paths = data['imagePaths'] as List<dynamic>;
        _capturedImages = paths.map((path) => File(path.toString())).toList();
      }
    }
  }

  void _loadExistingData(Map data) {
    clientNameController.text = data['clientName']?.toString() ?? '';
    productNameController.text = data['productName']?.toString() ?? '';
    productCodeController.text = data['productCode']?.toString() ?? '';
    lengthController.text = data['length']?.toString() ?? '';
    widthController.text = data['width']?.toString() ?? '';
    heightController.text = data['height']?.toString() ?? '';
    result = data['result']?.toString() ?? '';

    // الحل الآمن للتقسيم
    final resultLines = result.split('\n');
    sheetLengthResult = resultLines.isNotEmpty ? resultLines[0] : '';
    sheetWidthResult = resultLines.length > 1 ? resultLines[1] : '';

    productionWidth1 = data['productionWidth1']?.toString() ?? '';
    productionWidth2 = data['productionWidth2']?.toString() ?? '';
    productionHeight = data['productionHeight']?.toString() ?? '';
    isOverFlap = data['isOverFlap'] ?? false;
    isFlap = data['isFlap'] ?? true;
    isOneFlap = data['isOneFlap'] ?? false;
    isTwoFlap = data['isTwoFlap'] ?? true;
    addTwoMm = data['addTwoMm'] ?? false;
    isFullSize = data['isFullSize'] ?? true;
    isQuarterSize = data['isQuarterSize'] ?? false;
    isQuarterWidth = data['isQuarterWidth'] ?? true;
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.isNotEmpty ? cameras.first : throw Exception(),
      );

      final quality = await getCameraResolution();

      _cameraController =
          CameraController(backCamera, quality, enableAudio: false);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    } catch (e) {
      _showErrorDialog(
          "الكاميرا غير متاحة", "لا يمكن تهيئة الكاميرا على هذا الجهاز.");
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    setState(() => _isProcessing = true);
    try {
      final directory = await getTemporaryDirectory();
      final imagePath =
          join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      XFile imageFile = await _cameraController!.takePicture();
      await File(imageFile.path).copy(imagePath);
      setState(() {
        _capturedImages.add(File(imagePath));
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog("فشل في التقاط الصورة", "حدث خطأ أثناء التقاط الصورة.");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("حسنًا"),
          ),
        ],
      ),
    );
  }

  void saveSheetSize() {
    final newRecord = {
      'clientName': clientNameController.text,
      'productName': productNameController.text,
      'productCode': productCodeController.text,
      'length': lengthController.text,
      'width': widthController.text,
      'height': heightController.text,
      'result': result,
      'productionWidth1': productionWidth1,
      'productionWidth2': productionWidth2,
      'productionHeight': productionHeight,
      'isOverFlap': isOverFlap,
      'isFlap': isFlap,
      'isOneFlap': isOneFlap,
      'isTwoFlap': isTwoFlap,
      'addTwoMm': addTwoMm,
      'isFullSize': isFullSize,
      'isQuarterSize': isQuarterSize,
      'isQuarterWidth': isQuarterWidth,
      'imagePaths': _capturedImages.map((file) => file.path).toList(),
      'date': DateTime.now().toIso8601String(),
    };

    // تعديل: إذا كان هناك key، استخدم put(key, ...) مباشرة
    if (widget.existingDataKey != null) {
      savedSheetSizesBox.put(widget.existingDataKey, newRecord);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث المقاس بنجاح!")),
      );
      Navigator.pop(context);
      return;
    }

    // في حالة الإضافة الجديدة، تحقق من التكرار
    bool isDuplicate = false;
    dynamic duplicateKey;

    for (final key in savedSheetSizesBox.keys) {
      final existingRecord = savedSheetSizesBox.get(key) as Map;
      if (existingRecord['clientName'] == newRecord['clientName'] &&
          existingRecord['productCode'] == newRecord['productCode']) {
        if (isQuarterSize) {
          if (existingRecord['isQuarterSize'] == true &&
              existingRecord['isQuarterWidth'] == isQuarterWidth) {
            isDuplicate = true;
            duplicateKey = key;
            break;
          }
        } else {
          isDuplicate = true;
          duplicateKey = key;
          break;
        }
      }
    }

    if (isDuplicate) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("تنبيه"),
          content: const Text("هذا المقاس موجود بالفعل. هل تريد استبداله؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("لا"),
            ),
            TextButton(
              onPressed: () {
                savedSheetSizesBox.put(duplicateKey, newRecord);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم تحديث المقاس بنجاح!")),
                );
                Navigator.pop(context);
              },
              child: const Text("نعم"),
            ),
          ],
        ),
      );
    } else {
      savedSheetSizesBox.add(newRecord);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حفظ المقاس بنجاح!")),
      );
      Navigator.pop(context);
    }
  }

  void calculateSheet() {
    double length = double.tryParse(lengthController.text) ?? 0.0;
    double width = double.tryParse(widthController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;
    double sheetLength = 0.0;
    double sheetWidth = 0.0;

    if (isFullSize) {
      sheetLength = ((length + width) * 2) + 4;
    } else if (isQuarterSize) {
      if (isQuarterWidth) {
        sheetLength = width + 4;
      } else {
        sheetLength = length + 4;
      }
    } else {
      sheetLength = length + width + 4;
    }

    if (isOverFlap && isTwoFlap) {
      sheetWidth = addTwoMm ? height + (width * 2) + 0.4 : height + (width * 2);
    } else if (isOverFlap && isOneFlap) {
      sheetWidth = addTwoMm ? height + width + 0.2 : height + width;
    } else if (isFlap && isTwoFlap) {
      sheetWidth = addTwoMm ? height + width + 0.4 : height + width;
    } else if (isFlap && isOneFlap) {
      sheetWidth = addTwoMm ? height + (width / 2) + 0.2 : height + (width / 2);
    }

    productionHeight = height.toStringAsFixed(2);

    if (isOverFlap && isTwoFlap) {
      productionWidth1 = addTwoMm
          ? (width + 0.2).toStringAsFixed(2)
          : width.toStringAsFixed(2);
      productionWidth2 = productionWidth1;
    } else if (isOverFlap && isOneFlap) {
      productionWidth1 = ".....";
      productionWidth2 = addTwoMm
          ? (width + 0.2).toStringAsFixed(2)
          : width.toStringAsFixed(2);
    } else if (isFlap && isTwoFlap) {
      productionWidth1 = addTwoMm
          ? ((width / 2) + 0.2).toStringAsFixed(2)
          : (width / 2).toStringAsFixed(2);
      productionWidth2 = productionWidth1;
    } else if (isFlap && isOneFlap) {
      productionWidth1 = ".....";
      productionWidth2 = addTwoMm
          ? ((width / 2) + 0.2).toStringAsFixed(2)
          : (width / 2).toStringAsFixed(2);
    } else {
      productionWidth1 = productionWidth2 = ".....";
    }

    setState(() {
      sheetLengthResult = "طول الشيت: ${sheetLength.toStringAsFixed(2)} سم";
      sheetWidthResult = "عرض الشيت: ${sheetWidth.toStringAsFixed(2)} سم";
      result = "$sheetLengthResult\n$sheetWidthResult";
    });
  }

  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    clientNameController.dispose();
    productNameController.dispose();
    productCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("مقاس الشيت"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveSheetSize,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: hideKeyboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildTextField("اسم العميل", clientNameController),
              buildTextField("اسم الصنف", productNameController),
              buildTextField("كود الصنف", productCodeController,
                  keyboardType: TextInputType.number),
              buildTextField("الطول", lengthController,
                  keyboardType: TextInputType.number),
              buildTextField("العرض", widthController,
                  keyboardType: TextInputType.number),
              buildTextField("الارتفاع", heightController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _buildCameraPreview(),
              const SizedBox(height: 20),
              buildCheckboxRow(
                "أوڨر فلاب",
                isOverFlap,
                (value) {
                  setState(() {
                    isOverFlap = value!;
                    isFlap = !value;
                  });
                },
                "فلاب",
                isFlap,
                (value) {
                  setState(() {
                    isFlap = value!;
                    isOverFlap = !value;
                  });
                },
              ),
              buildCheckboxRow(
                "1 فلاب",
                isOneFlap,
                (value) {
                  setState(() {
                    isOneFlap = value!;
                    isTwoFlap = !value;
                  });
                },
                "2 فلاب",
                isTwoFlap,
                (value) {
                  setState(() {
                    isTwoFlap = value!;
                    isOneFlap = !value;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("إضافة 2 مللم"),
                value: addTwoMm,
                onChanged: (value) {
                  setState(() {
                    addTwoMm = value!;
                  });
                },
              ),
              buildCheckboxRow(
                "ص",
                isFullSize,
                (value) {
                  setState(() {
                    isFullSize = value!;
                    isQuarterSize = false;
                  });
                },
                "1/2 ص",
                !isFullSize && !isQuarterSize,
                (value) {
                  setState(() {
                    isFullSize = !value!;
                    isQuarterSize = false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("1/4 ص"),
                value: isQuarterSize,
                onChanged: (value) {
                  setState(() {
                    isQuarterSize = value!;
                    isFullSize = false;
                  });
                },
              ),
              if (isQuarterSize)
                buildCheckboxRow(
                  "عرض",
                  isQuarterWidth,
                  (value) {
                    setState(() {
                      isQuarterWidth = value!;
                    });
                  },
                  "طول",
                  !isQuarterWidth,
                  (value) {
                    setState(() {
                      isQuarterWidth = !value!;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculateSheet,
                child: const Text("احسب"),
              ),
              const SizedBox(height: 20),
              Text(sheetLengthResult,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(sheetWidthResult,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("مقاسات خط الإنتاج",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      buildTableCell(productionWidth1),
                      buildTableCell(productionHeight),
                      buildTableCell(productionWidth2),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Column(
      children: [
        if (_isCameraReady &&
            _cameraController != null &&
            _cameraController!.value.isInitialized)
          SizedBox(
            height: 200,
            child: CameraPreview(_cameraController!),
          ),
        if (!_isCameraReady)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("الكاميرا غير متاحة على هذا الجهاز"),
          ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _captureImage,
          icon: const Icon(Icons.camera),
          label: const Text("التقط صورة"),
        ),
        const SizedBox(height: 10),
        if (_capturedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _capturedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        _capturedImages[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.red),
                        onPressed: () => _removeImage(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : null,
        onSubmitted: (_) => hideKeyboard(),
      ),
    );
  }

  Widget buildCheckboxRow(
    String title1,
    bool value1,
    Function(bool?) onChanged1,
    String title2,
    bool value2,
    Function(bool?) onChanged2,
  ) {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            title: Text(title1),
            value: value1,
            onChanged: onChanged1,
          ),
        ),
        Expanded(
          child: CheckboxListTile(
            title: Text(title2),
            value: value2,
            onChanged: onChanged2,
          ),
        ),
      ],
    );
  }

  Widget buildTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
