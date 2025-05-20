// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import '../widgets/results_widget.dart';
import 'package:hive/hive.dart';

class SerialSetupScreen extends StatefulWidget {
  const SerialSetupScreen({super.key});

  @override
  _SerialSetupScreenState createState() => _SerialSetupScreenState();
}

class _SerialSetupScreenState extends State<SerialSetupScreen> {
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController bladeController = TextEditingController();

  bool isWidthActive = true;

  double? a1, t1, a2, t2;

  // Hive box for persistent state
  Box? serialSetupStateBox;

  String convertToWesternNumbers(String input) {
    const arabicToWestern = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9'
    };
    return input.split('').map((char) => arabicToWestern[char] ?? char).join();
  }

  void calculateValues() {
    final double length =
        double.tryParse(convertToWesternNumbers(lengthController.text)) ?? 0.0;
    final double width =
        double.tryParse(convertToWesternNumbers(widthController.text)) ?? 0.0;
    final double blade =
        double.tryParse(convertToWesternNumbers(bladeController.text)) ?? 0.0;

    if (isWidthActive) {
      a1 = blade + (width / 2);
      t1 = blade + width + (length / 2);
      a2 = blade + width + length + (width / 2);
      t2 = blade + width + length + width + (length / 2);
    } else {
      t1 = blade + (length / 2);
      a1 = blade + length + (width / 2);
      t2 = blade + length + width + (length / 2);
      a2 = blade + length + width + length + (width / 2);
    }

    setState(() {});
    saveState(); // Save state after calculation
  }

  void toggleCheckbox(bool? value) {
    setState(() {
      isWidthActive = value ?? true;
      calculateValues();
    });
  }

  void clearFields() {
    setState(() {
      lengthController.clear();
      widthController.clear();
      bladeController.clear();
      a1 = null;
      t1 = null;
      a2 = null;
      t2 = null;
      isWidthActive = true; // Reset the checkbox to default
    });
    saveState(); // Save cleared state
  }

  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    // Initialize Hive box asynchronously
    Future.microtask(() async {
      await initializeHiveBox();
      restoreState();
    });
  }

  Future<void> initializeHiveBox() async {
    if (!Hive.isBoxOpen('serialSetupState')) {
      await Hive.openBox('serialSetupState');
    }
    setState(() {
      serialSetupStateBox = Hive.box('serialSetupState');
    });
  }

  void restoreState() {
    if (serialSetupStateBox == null) return; // Ensure box is initialized
    final state = serialSetupStateBox!.get('state');
    if (state != null) {
      setState(() {
        lengthController.text = state['length'] ?? '';
        widthController.text = state['width'] ?? '';
        bladeController.text = state['blade'] ?? '';
        a1 = state['a1'];
        t1 = state['t1'];
        a2 = state['a2'];
        t2 = state['t2'];
        isWidthActive = state['isWidthActive'] ?? true;
      });
    }
  }

  void saveState() {
    if (serialSetupStateBox == null) return; // Ensure box is initialized
    final state = {
      'length': lengthController.text,
      'width': widthController.text,
      'blade': bladeController.text,
      'a1': a1,
      't1': t1,
      'a2': a2,
      't2': t2,
      'isWidthActive': isWidthActive,
    };
    serialSetupStateBox!.put('state', state);
  }

  @override
  void dispose() {
    saveState(); // Save state before disposing
    lengthController.dispose();
    widthController.dispose();
    bladeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا

      appBar: AppBar(
        centerTitle: true,
        title: const Text("ضبط تركيب السيريل"),
        actions: const [],
      ),
      body: GestureDetector(
        onTap: hideKeyboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: lengthController,
                decoration: const InputDecoration(labelText: 'أدخل الطول'),
                keyboardType: TextInputType.number,
                onSubmitted: (_) {
                  hideKeyboard();
                  calculateValues();
                },
              ),
              TextField(
                controller: widthController,
                decoration: const InputDecoration(labelText: 'أدخل العرض'),
                keyboardType: TextInputType.number,
                onSubmitted: (_) {
                  hideKeyboard();
                  calculateValues();
                },
              ),
              TextField(
                controller: bladeController,
                decoration:
                    const InputDecoration(labelText: 'أدخل السلاح الأول'),
                keyboardType: TextInputType.number,
                onSubmitted: (_) {
                  hideKeyboard();
                  calculateValues();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isWidthActive,
                    onChanged: toggleCheckbox,
                  ),
                  const Text('اللسان في العرض'),
                  const SizedBox(width: 20),
                  Checkbox(
                    value: !isWidthActive,
                    onChanged: (value) => toggleCheckbox(!value!),
                  ),
                  const Text('اللسان في الطول'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      hideKeyboard();
                      calculateValues();
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('حساب'),
                  ),
                  ElevatedButton(
                    onPressed: clearFields,
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('مسح الحقول'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ResultsWidget(
                  a1: isWidthActive ? a1 : t1,
                  t1: isWidthActive ? t1 : a1,
                  a2: isWidthActive ? a2 : t2,
                  t2: isWidthActive ? t2 : a2,
                  isWidthActive: isWidthActive,
                  labels: isWidthActive
                      ? ["ع1", "ط1", "ع2", "ط2"]
                      : ["ط1", "ع1", "ط2", "ع2"],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
