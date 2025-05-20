import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final Box _maintenanceBox = Hive.box('maintenanceRecords');

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.text.trim().isNotEmpty
          ? DateTime.tryParse(controller.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _addOrEditMaintenance({int? index, Map<String, dynamic>? existingData}) {
    final TextEditingController issueDateController =
        TextEditingController(text: existingData?['issueDate'] ?? '');
    final TextEditingController machineController =
        TextEditingController(text: existingData?['machine'] ?? '');
    final TextEditingController issueDescController =
        TextEditingController(text: existingData?['issueDescription'] ?? '');
    final TextEditingController reportDateController =
        TextEditingController(text: existingData?['reportDate'] ?? '');
    final TextEditingController reportedToTechnicianController =
        TextEditingController(
            text: existingData?['reportedToTechnician'] ?? '');
    final TextEditingController actionController =
        TextEditingController(text: existingData?['actionTaken'] ?? '');
    final TextEditingController actionDateController =
        TextEditingController(text: existingData?['actionDate'] ?? '');
    bool isFixed = existingData?['isFixed'] ?? false;
    String repairLocation = existingData?['repairLocation'] ?? 'في المصنع';
    final TextEditingController repairedByController =
        TextEditingController(text: existingData?['repairedBy'] ?? '');
    final TextEditingController notesController =
        TextEditingController(text: existingData?['notes'] ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(index == null ? "إضافة سجل صيانة" : "تعديل سجل الصيانة"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: issueDateController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(labelText: "📅 تاريخ ظهور العطل"),
                  onTap: () => _selectDate(context, issueDateController),
                ),
                TextField(
                  controller: machineController,
                  decoration:
                      const InputDecoration(labelText: "🏭 اسم الماكينة"),
                ),
                TextField(
                  controller: issueDescController,
                  decoration: const InputDecoration(labelText: "⚠️ وصف العطل"),
                ),
                TextField(
                  controller: reportDateController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(labelText: "🗓️ تاريخ التبليغ"),
                  onTap: () => _selectDate(context, reportDateController),
                ),
                TextField(
                  controller: reportedToTechnicianController,
                  decoration: const InputDecoration(
                      labelText: "👷‍♂️ تم التبليغ إلى (اسم الفني)"),
                ),
                TextField(
                  controller: actionController,
                  decoration:
                      const InputDecoration(labelText: "🔧 الإجراء المتخذ"),
                ),
                TextField(
                  controller: actionDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: "📆 تاريخ تنفيذ الإجراء"),
                  onTap: () => _selectDate(context, actionDateController),
                ),
                Row(
                  children: [
                    const Text("✅ تم إصلاح العطل؟"),
                    Checkbox(
                      value: isFixed,
                      onChanged: (val) =>
                          setState(() => isFixed = val ?? false),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: repairLocation,
                  items: const [
                    DropdownMenuItem(
                        value: 'في المصنع', child: Text('في المصنع')),
                    DropdownMenuItem(
                        value: 'ورشة خارجية', child: Text('ورشة خارجية')),
                  ],
                  onChanged: (val) =>
                      setState(() => repairLocation = val ?? 'في المصنع'),
                  decoration:
                      const InputDecoration(labelText: "🏠 مكان الإصلاح"),
                ),
                TextField(
                  controller: repairedByController,
                  decoration:
                      const InputDecoration(labelText: "🛠 تم الإصلاح بواسطة"),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: "📝 ملاحظات"),
                ),
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
                  'issueDate': issueDateController.text,
                  'machine': machineController.text,
                  'issueDescription': issueDescController.text,
                  'reportDate': reportDateController.text,
                  'reportedToTechnician': reportedToTechnicianController.text,
                  'actionTaken': actionController.text,
                  'actionDate': actionDateController.text,
                  'isFixed': isFixed,
                  'repairLocation': repairLocation,
                  'repairedBy': repairedByController.text,
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
      ),
    );
  }

  void _deleteMaintenance(int index) {
    _maintenanceBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("🛠 سجلات الصيانة"),
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
                  title: Text("📅 تاريخ العطل: ${record['issueDate'] ?? ''}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🏭 الماكينة: ${record['machine'] ?? ''}"),
                      Text("⚠️ وصف العطل: ${record['issueDescription'] ?? ''}"),
                      Text("🗓️ تاريخ التبليغ: ${record['reportDate'] ?? ''}"),
                      Text(
                          "👷‍♂️ تم التبليغ إلى: ${record['reportedToTechnician'] ?? ''}"),
                      Text("🔧 الإجراء: ${record['actionTaken'] ?? ''}"),
                      Text("📆 تاريخ الإجراء: ${record['actionDate'] ?? ''}"),
                      Text(
                          "✅ تم الإصلاح: ${(record['isFixed'] ?? false) ? 'نعم' : 'لا'}"),
                      Text(
                          "🏠 مكان الإصلاح: ${record['repairLocation'] ?? ''}"),
                      Text(
                          "🛠 تم الإصلاح بواسطة: ${record['repairedBy'] ?? ''}"),
                      if (record['notes'] != null &&
                          record['notes'].toString().isNotEmpty)
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
