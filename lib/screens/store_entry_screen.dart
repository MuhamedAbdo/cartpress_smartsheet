// ignore_for_file: library_private_types_in_public_api

import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StoreEntryScreen extends StatefulWidget {
  const StoreEntryScreen({super.key});

  @override
  _StoreEntryScreenState createState() => _StoreEntryScreenState();
}

class _StoreEntryScreenState extends State<StoreEntryScreen> {
  final Box _storeEntryBox = Hive.box('storeEntries');
  final TextEditingController dateController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // Check if pickedDate is not null before accessing its properties
    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  void _saveStoreEntry({int? index, Map<String, dynamic>? existingData}) {
    final record = {
      'date': dateController.text,
      'product': productController.text,
      'unit': unitController.text,
      'quantity': quantityController.text,
      'notes': notesController.text,
    };
    if (index == null) {
      _storeEntryBox.add(record);
    } else {
      _storeEntryBox.putAt(index, record);
    }
    Navigator.pop(context);
  }

  void _showStoreEntryDialog({int? index, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      dateController.text = existingData['date'];
      productController.text = existingData['product'];
      unitController.text = existingData['unit'];
      quantityController.text = existingData['quantity'];
      notesController.text = existingData['notes'];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(index == null
              ? "إضافة تقرير وارد المخزن"
              : "تعديل تقرير وارد المخزن"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "📅 التاريخ"),
                  onTap: () => _selectDate(context),
                ),
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(labelText: "📦 الصنف"),
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: "📏 الوحدة"),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType:
                      TextInputType.number, // لتفعيل لوحة المفاتيح الرقمية
                  decoration: const InputDecoration(labelText: "🔢 العدد"),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                      labelText: "📝 الملاحظات (إن وجدت)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("❌ إلغاء"),
            ),
            ElevatedButton(
              onPressed: () =>
                  _saveStoreEntry(index: index, existingData: existingData),
              child: const Text("💾 حفظ"),
            ),
          ],
        ),
      ),
    ).then((_) {
      dateController.clear();
      productController.clear();
      unitController.clear();
      quantityController.clear();
      notesController.clear();
    });
  }

  void _deleteStoreEntry(int index) {
    _storeEntryBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا

      appBar: AppBar(
        centerTitle: true,
        title: const Text("📄 تقارير وارد المخزن"),
        actions: const [],
      ),
      body: ValueListenableBuilder(
        valueListenable: _storeEntryBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
                child: Text("🚫 لا يوجد تقارير وارد المخزن بعد"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final record = box.getAt(index) as Map<dynamic, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("📅 ${record['date']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📦 الصنف: ${record['product']}"),
                      Text("📏 الوحدة: ${record['unit']}"),
                      Text("🔢 العدد: ${record['quantity']}"),
                      if (record['notes'] != null && record['notes'].isNotEmpty)
                        Text("📝 ملاحظات: ${record['notes']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showStoreEntryDialog(
                            index: index,
                            existingData: Map<String, dynamic>.from(record)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteStoreEntry(index),
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
        onPressed: () => _showStoreEntryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
