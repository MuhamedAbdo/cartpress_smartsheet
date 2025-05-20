import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:cartpress_smartsheet/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class SheetCountScreen extends StatefulWidget {
  const SheetCountScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SheetCountScreenState createState() => _SheetCountScreenState();
}

class _SheetCountScreenState extends State<SheetCountScreen> {
  late Box settingsBox;
  bool isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
    isDarkTheme = settingsBox.get('isDarkTheme', defaultValue: false);
  }

  final TextEditingController firstSheetLengthController =
      TextEditingController();
  final TextEditingController firstSheetCountController =
      TextEditingController();
  final TextEditingController secondSheetLengthController =
      TextEditingController();

  String result = "";

  void calculateSheetCount() {
    double firstLength = double.tryParse(
            convertToEnglishNumbers(firstSheetLengthController.text)) ??
        0;
    int firstCount =
        int.tryParse(convertToEnglishNumbers(firstSheetCountController.text)) ??
            0;
    double secondLength = double.tryParse(
            convertToEnglishNumbers(secondSheetLengthController.text)) ??
        1;

    int secondCount = ((firstLength * firstCount) / secondLength).toInt();

    setState(() {
      result = "عدد الشيتات الثاني: ${secondCount.toString()}";
    });
  }

  String convertToEnglishNumbers(String input) {
    return input
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');
  }

  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا

      appBar: AppBar(
        centerTitle: true,
        title: const Text("عدد الشيتات"),
        actions: const [],
      ),
      body: GestureDetector(
        onTap: hideKeyboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildTextField("طول الشيت الأول", firstSheetLengthController),
              buildTextField("عدد الشيت الأول", firstSheetCountController),
              buildTextField("طول الشيت الثاني", secondSheetLengthController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: calculateSheetCount,
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("احسب"),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                result,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
