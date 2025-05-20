import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MaintenanceSection extends StatefulWidget {
  final String boxName; // اسم الصندوق يُمرر ليكون لكل ماكينة بيانات مستقلة
  final String? title; // عنوان مخصص للصفحة (اختياري)

  const MaintenanceSection({
    Key? key,
    required this.boxName,
    this.title,
  }) : super(key: key);

  @override
  _MaintenanceSectionState createState() => _MaintenanceSectionState();
}

class _MaintenanceSectionState extends State<MaintenanceSection> {
  late TextEditingController issueDateController;
  late TextEditingController machineController;
  late TextEditingController issueDescController;
  late TextEditingController reportDateController;
  late TextEditingController reportedToTechnicianController;
  late TextEditingController actionController;
  late TextEditingController actionDateController;
  late TextEditingController repairedByController;
  late TextEditingController notesController;

  bool isFixed = false;
  String repairLocation = 'في المصنع';

  late Box _maintenanceBox;

  @override
  void initState() {
    super.initState();

    // تهيئة الكونترولرز
    issueDateController = TextEditingController();
    machineController = TextEditingController();
    issueDescController = TextEditingController();
    reportDateController = TextEditingController();
    reportedToTechnicianController = TextEditingController();
    actionController = TextEditingController();
    actionDateController = TextEditingController();
    repairedByController = TextEditingController();
    notesController = TextEditingController();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
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
    // إعادة تعيين القيم الحالية
    issueDateController.text = existingData?['issueDate'] ?? '';
    machineController.text = existingData?['machine'] ?? '';
    issueDescController.text = existingData?['issueDescription'] ?? '';
    reportDateController.text = existingData?['reportDate'] ?? '';
    reportedToTechnicianController.text =
        existingData?['reportedToTechnician'] ?? '';
    actionController.text = existingData?['actionTaken'] ?? '';
    actionDateController.text = existingData?['actionDate'] ?? '';
    isFixed = existingData?['isFixed'] ?? false;
    repairLocation = existingData?['repairLocation'] ?? 'في المصنع';
    repairedByController.text = existingData?['repairedBy'] ?? '';
    notesController.text = existingData?['notes'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
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
                    const Text("✅ تم الإصلاح؟"),
                    Checkbox(
                      value: isFixed,
                      onChanged: (val) =>
                          setStateDialog(() => isFixed = val ?? false),
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
                      setStateDialog(() => repairLocation = val ?? 'في المصنع'),
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
              onPressed: () {
                Navigator.pop(context);
                // إعادة تعيين الحقول بعد إلغاء
                issueDateController.clear();
                machineController.clear();
                issueDescController.clear();
                reportDateController.clear();
                reportedToTechnicianController.clear();
                actionController.clear();
                actionDateController.clear();
                repairedByController.clear();
                notesController.clear();
              },
              child: const Text("❌ إلغاء"),
            ),
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

                // إعادة تعيين الحقول بعد الحفظ
                issueDateController.clear();
                machineController.clear();
                issueDescController.clear();
                reportDateController.clear();
                reportedToTechnicianController.clear();
                actionController.clear();
                actionDateController.clear();
                repairedByController.clear();
                notesController.clear();

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
  void dispose() {
    issueDateController.dispose();
    machineController.dispose();
    issueDescController.dispose();
    reportDateController.dispose();
    reportedToTechnicianController.dispose();
    actionController.dispose();
    actionDateController.dispose();
    repairedByController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox(widget.boxName), // ← فتح الصندوق بطريقة آمنة
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text("❌ لم يتم فتح الصندوق: ${snapshot.error}"),
            );
          }

          _maintenanceBox = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(widget.title ?? "🛠 سجلات الصيانة"),
            ),
            body: ValueListenableBuilder<Box>(
              valueListenable: _maintenanceBox.listenable(),
              builder: (context, box, _) {
                if (box.isEmpty) {
                  return const Center(
                      child: Text("🚫 لا يوجد سجلات صيانة بعد"));
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final record = box.getAt(index); // dynamic
                    if (record is Map) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                              "📅 تاريخ العطل: ${record['issueDate'] ?? ''}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("🏭 الماكينة: ${record['machine'] ?? ''}"),
                              Text(
                                  "⚠️ وصف العطل: ${record['issueDescription'] ?? ''}"),
                              Text(
                                  "🗓️ تاريخ التبليغ: ${record['reportDate'] ?? ''}"),
                              Text(
                                  "👷‍♂️ تم التبليغ إلى: ${record['reportedToTechnician'] ?? ''}"),
                              Text(
                                  "🔧 الإجراء: ${record['actionTaken'] ?? ''}"),
                              Text(
                                  "📆 تاريخ الإجراء: ${record['actionDate'] ?? ''}"),
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
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _addOrEditMaintenance(
                                    index: index,
                                    existingData:
                                        Map<String, dynamic>.from(record)),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteMaintenance(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(); // أو رسالة خطأ
                    }
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _addOrEditMaintenance(),
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
