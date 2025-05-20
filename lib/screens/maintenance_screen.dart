import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final Box _maintenanceBox = Hive.box('maintenanceRecords');

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // Check if pickedDate is not null before accessing its properties
    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  void _addOrEditMaintenance({int? index, Map<String, dynamic>? existingData}) {
    final TextEditingController dateController =
        TextEditingController(text: existingData?['date'] ?? '');
    final TextEditingController machineController =
        TextEditingController(text: existingData?['machine'] ?? '');
    final TextEditingController issueController =
        TextEditingController(text: existingData?['issue'] ?? '');
    final TextEditingController technicianController =
        TextEditingController(text: existingData?['technician'] ?? '');
    final TextEditingController actionController =
        TextEditingController(text: existingData?['action'] ?? '');
    final TextEditingController notesController =
        TextEditingController(text: existingData?['notes'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? "إضافة سجل صيانة" : "تعديل سجل الصيانة"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "📅 التاريخ"),
                onTap: () => _selectDate(context, dateController),
              ),
              TextField(
                  controller: machineController,
                  decoration:
                      const InputDecoration(labelText: "🏭 اسم الماكينة")),
              TextField(
                  controller: issueController,
                  decoration: const InputDecoration(labelText: "⚠️ العطل")),
              TextField(
                  controller: technicianController,
                  decoration: const InputDecoration(labelText: "🛠 الفني")),
              TextField(
                  controller: actionController,
                  decoration: const InputDecoration(labelText: "🔧 الإجراء")),
              TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                      labelText: "📝 الملاحظات (اختياري)")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("❌ إلغاء")),
          ElevatedButton(
            onPressed: () {
              final record = {
                'date': dateController.text,
                'machine': machineController.text,
                'issue': issueController.text,
                'technician': technicianController.text,
                'action': actionController.text,
                'notes': notesController.text,
              };
              if (index == null) {
                _maintenanceBox.add(record);
              } else {
                _maintenanceBox.putAt(index, record);
              }
              Navigator.pop(context);
            },
            child: const Text("💾 حفظ"),
          ),
        ],
      ),
    );
  }

  void _deleteMaintenance(int index) {
    _maintenanceBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا

      appBar: AppBar(
        centerTitle: true,
        title: const Text("🛠 سجلات الصيانة"),
        actions: const [],
      ),
      body: ValueListenableBuilder(
        valueListenable: _maintenanceBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("🚫 لا يوجد سجلات صيانة بعد"));
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
                      Text("📦 الماكينة: ${record['machine']}"),
                      Text("⚠️ العطل: ${record['issue']}"),
                      Text("🛠 الفني: ${record['technician']}"),
                      Text("🔧 الإجراء: ${record['action']}"),
                      if (record['notes'] != null && record['notes'].isNotEmpty)
                        Text("📝 ملاحظات: ${record['notes']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditMaintenance(
                            index: index,
                            existingData: Map<String, dynamic>.from(record)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMaintenance(index),
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
        onPressed: () => _addOrEditMaintenance(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
