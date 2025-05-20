import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InkReportScreen extends StatefulWidget {
  final Map? initialData;

  const InkReportScreen({super.key, this.initialData});

  @override
  _InkReportScreenState createState() => _InkReportScreenState();
}

class _InkReportScreenState extends State<InkReportScreen> {
  late Box _inkReportBox;
  late TextEditingController dateController;
  late TextEditingController clientNameController;
  late TextEditingController productController;
  late TextEditingController productCodeController;
  late TextEditingController lengthController;
  late TextEditingController widthController;
  late TextEditingController heightController;
  late TextEditingController quantityController;
  late TextEditingController notesController;
  List<ColorField> colors = [];
  List<String>? preloadedImagePaths;
  String searchQuery = "";
  bool isSearching = false;

  // Camera
  CameraController? _cameraController;
  late bool _isCameraReady = false;
  final List<File> _capturedImages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _inkReportBox = Hive.box('inkReports');
    _initializeControllers();

    if (widget.initialData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInkReportDialog(context);
      });
    }
  }

  void _initializeControllers() {
    dateController = TextEditingController();
    clientNameController = TextEditingController();
    productController = TextEditingController();
    productCodeController = TextEditingController();
    lengthController = TextEditingController();
    widthController = TextEditingController();
    heightController = TextEditingController();
    quantityController = TextEditingController();
    notesController = TextEditingController();

    if (widget.initialData != null) {
      final data = Map<String, dynamic>.from(widget.initialData!);
      _loadInitialData(data);
    } else {
      dateController.text =
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    }
  }

  void _loadInitialData(Map<String, dynamic> data) {
    setState(() {
      dateController.text = data['date'] ?? '';
      clientNameController.text = data['clientName'] ?? '';
      productController.text = data['product'] ?? '';
      productCodeController.text = data['productCode'] ?? '';
      lengthController.text = data['dimensions']['length'].toString();
      widthController.text = data['dimensions']['width'].toString();
      heightController.text = data['dimensions']['height'].toString();

      // الصور إن وجدت
      preloadedImagePaths = data['imagePaths'] is List
          ? List<String>.from(data['imagePaths'])
          : [];

      if (preloadedImagePaths != null && preloadedImagePaths!.isNotEmpty) {
        _capturedImages.clear();
        _capturedImages.addAll(preloadedImagePaths!.map((p) => File(p)));
      }
    });
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
      debugPrint("Camera initialization error: $e");
    }
  }

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

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    setState(() => _isProcessing = true);
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = path.join(
          directory.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
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

  String _formatDecimal(String value) {
    if (value.startsWith('.')) return '0$value';
    return value;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  void _addColorField(StateSetter setStateDialog) {
    colors.add(ColorField(
      colorController: TextEditingController(),
      quantityController: TextEditingController(),
    ));
    setStateDialog(() {});
  }

  void _removeColorField(int index, StateSetter setStateDialog) {
    if (index >= 0 && index < colors.length) {
      colors[index].colorController.dispose();
      colors[index].quantityController.dispose();
      colors.removeAt(index);
      setStateDialog(() {});
    }
  }

  void _saveInkReport({int? index}) {
    try {
      final record = {
        'date': dateController.text,
        'clientName': clientNameController.text,
        'product': productController.text,
        'productCode': productCodeController.text,
        'dimensions': {
          'length': lengthController.text,
          'width': widthController.text,
          'height': heightController.text,
        },
        'colors': colors.map((color) {
          return {
            'color': color.colorController.text,
            'quantity': _formatDecimal(color.quantityController.text),
          };
        }).toList(),
        'quantity': quantityController.text,
        'notes': notesController.text,
        'imagePaths': _capturedImages.isNotEmpty
            ? _capturedImages.map((file) => file.path).toList()
            : preloadedImagePaths ?? [],
      };

      if (index == null) {
        _inkReportBox.add(record);
      } else {
        _inkReportBox.putAt(index, record);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("✅ تم ${index == null ? 'إضافة' : 'تحديث'} التقرير")),
      );
      Navigator.pop(context);
      _clearControllers();
    } catch (e) {
      debugPrint("❌ خطأ أثناء حفظ التقرير: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ حدث خطأ أثناء الحفظ: $e")),
      );
    }
  }

  void _clearControllers() {
    dateController.clear();
    clientNameController.clear();
    productController.clear();
    productCodeController.clear();
    lengthController.clear();
    widthController.clear();
    heightController.clear();
    quantityController.clear();
    notesController.clear();
    for (var color in colors) {
      color.colorController.dispose();
      color.quantityController.dispose();
    }
    colors.clear();
    _capturedImages.clear();
  }

  void _prefillDataFromExisting(Map<String, dynamic> existingData) {
    dateController.text = existingData['date'] ?? '';
    clientNameController.text = existingData['clientName'] ?? '';
    productController.text = existingData['product'] ?? '';
    productCodeController.text = existingData['productCode'] ?? '';
    lengthController.text =
        _formatDecimal(existingData['dimensions']['length'] ?? '');
    widthController.text =
        _formatDecimal(existingData['dimensions']['width'] ?? '');
    heightController.text =
        _formatDecimal(existingData['dimensions']['height'] ?? '');
    quantityController.text = existingData['quantity'] ?? '';
    notesController.text = existingData['notes'] ?? '';

    if (existingData.containsKey('colors') && existingData['colors'] is List) {
      colors = (existingData['colors'] as List).map((color) {
        return ColorField(
          colorController: TextEditingController(text: color['color']),
          quantityController: TextEditingController(text: color['quantity']),
        );
      }).toList();
    }

    preloadedImagePaths = existingData['imagePaths'] is List
        ? List<String>.from(existingData['imagePaths'])
        : [];
  }

  void _showInkReportDialog(BuildContext context,
      {int? index, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      _prefillDataFromExisting(Map<String, dynamic>.from(existingData));
    } else {
      dateController.text =
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      clientNameController.clear();
      productController.clear();
      productCodeController.clear();
      lengthController.clear();
      widthController.clear();
      heightController.clear();
      quantityController.clear();
      notesController.clear();
      colors.clear();
      _capturedImages.clear();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: Text(index == null ? "إضافة تقرير حبر" : "تعديل تقرير"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: "📅 التاريخ"),
                      onTap: () => _selectDate(dialogContext),
                    ),
                    TextField(
                      controller: clientNameController,
                      decoration:
                          const InputDecoration(labelText: "👤 اسم العميل"),
                    ),
                    TextField(
                      controller: productController,
                      decoration: const InputDecoration(labelText: "📦 الصنف"),
                    ),
                    TextField(
                      controller: productCodeController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "🔢 كود الصنف"),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lengthController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "📏 الطول"),
                            onChanged: (value) {
                              lengthController.text = _formatDecimal(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widthController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "📏 العرض"),
                            onChanged: (value) {
                              widthController.text = _formatDecimal(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "📏 الارتفاع"),
                            onChanged: (value) {
                              heightController.text = _formatDecimal(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    // الكاميرا ومعاينة الصور
                    if (_isCameraReady && _cameraController != null)
                      Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: CameraPreview(_cameraController!),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _captureImage,
                            icon: const Icon(Icons.camera),
                            label: const Text("التقط صورة"),
                          ),
                        ],
                      ),

                    if (_capturedImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _capturedImages.length,
                          itemBuilder: (context, imgIndex) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.file(
                                    _capturedImages[imgIndex],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        size: 18, color: Colors.red),
                                    onPressed: () {
                                      setStateDialog(() {
                                        _removeImage(imgIndex);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    // ألوان الأحبار
                    ...colors.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final colorField = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: colorField.colorController,
                                decoration: const InputDecoration(
                                    labelText: "🎨 اللون"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: colorField.quantityController,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                decoration: const InputDecoration(
                                    labelText: "💧 الكمية باللتر"),
                                onChanged: (value) {
                                  colorField.quantityController.text =
                                      _formatDecimal(value);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _removeColorField(idx, setStateDialog),
                            )
                          ],
                        ),
                      );
                    }),

                    ElevatedButton.icon(
                      onPressed: () => _addColorField(setStateDialog),
                      icon: const Icon(Icons.add),
                      label: const Text("إضافة لون"),
                    ),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "🔢 عدد الشيتات"),
                    ),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: "📝 ملاحظات (اختياري)"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _clearControllers();
                  },
                  child: const Text("❌ إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () => _saveInkReport(index: index),
                  child: const Text("💾 حفظ التقرير"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteInkReport(int index) {
    _inkReportBox.deleteAt(index);
  }

  void _showFullScreenImage(String imagePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: PhotoView(
                imageProvider: FileImage(File(imagePath)),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    dateController.dispose();
    clientNameController.dispose();
    productController.dispose();
    productCodeController.dispose();
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    quantityController.dispose();
    notesController.dispose();
    for (var color in colors) {
      color.colorController.dispose();
      color.quantityController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: isSearching
            ? TextField(
                decoration: InputDecoration(
                  hintText: "بحث...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black45,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              )
            : const Text("📄 تقارير الأحبار"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) searchQuery = "";
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _inkReportBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("🚫 لا يوجد تقارير حبر بعد"));
          }

          final filteredRecords = box.values.where((record) {
            final recordMap = record as Map;
            final clientName =
                recordMap['clientName']?.toString().toLowerCase() ?? "";
            final productCode =
                recordMap['productCode']?.toString().toLowerCase() ?? "";
            final productName =
                recordMap['product']?.toString().toLowerCase() ?? "";
            final query = searchQuery.toLowerCase();

            if (searchQuery.isNotEmpty) {
              if (int.tryParse(searchQuery) != null) {
                return productCode.contains(query);
              } else {
                return clientName.contains(query) ||
                    productName.contains(query) ||
                    productCode.contains(query);
              }
            }
            return true;
          }).toList()
            ..sort((a, b) {
              final dateA = a['date'] ?? '';
              final dateB = b['date'] ?? '';
              final timeA = DateTime.tryParse(dateA);
              final timeB = DateTime.tryParse(dateB);
              if (timeA != null && timeB != null) {
                return timeB.compareTo(timeA); // الأحدث أولًا
              }
              return b['date'].compareTo(a['date']);
            });

          if (filteredRecords.isEmpty) {
            return const Center(child: Text("🚫 لا توجد نتائج للبحث."));
          }

          return ListView.builder(
            itemCount: filteredRecords.length,
            itemBuilder: (context, idx) {
              final record = Map<String, dynamic>.from(filteredRecords[idx]);
              final List<String> imagePaths = record['imagePaths'] is List
                  ? List<String>.from(record['imagePaths'])
                  : [];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("📅 التاريخ: ${record['date']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 اسم العميل: ${record['clientName']}"),
                      Text("📦 الصنف: ${record['product']}"),
                      Text("🔢 كود الصنف: ${record['productCode'] ?? ''}"),
                      Text(
                          "📏 المقاس: طول ${record['dimensions']['length']} × عرض ${record['dimensions']['width']} × ارتفاع ${record['dimensions']['height']}"),
                      if (record['colors'].isNotEmpty)
                        ...record['colors'].map<Widget>((color) {
                          return Text(
                              "🎨 اللون: ${color['color']}، الكمية: ${color['quantity']} لتر");
                        }).toList(),
                      Text("🔢 عدد الشيتات: ${record['quantity']}"),
                      if (record['notes'] != null && record['notes'].isNotEmpty)
                        Text("📝 ملاحظات: ${record['notes']}"),
                      if (imagePaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imagePaths.length,
                              itemBuilder: (context, imgIndex) {
                                final imagePath = imagePaths[imgIndex];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: FutureBuilder<bool>(
                                    future: File(imagePath).exists(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox.square(
                                          dimension: 50,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      }
                                      if (snapshot.hasData && snapshot.data!) {
                                        return GestureDetector(
                                          onTap: () =>
                                              _showFullScreenImage(imagePath),
                                          child: Image.file(
                                            File(imagePath),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else {
                                        return const Icon(Icons.broken_image,
                                            size: 30, color: Colors.red);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _prefillDataFromExisting(record);
                          _showInkReportDialog(context, existingData: record);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteInkReport(idx),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInkReportDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ColorField {
  final TextEditingController colorController;
  final TextEditingController quantityController;

  ColorField({
    required this.colorController,
    required this.quantityController,
  });
}
