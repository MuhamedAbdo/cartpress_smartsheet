import 'package:flutter/material.dart';
import 'package:cartpress_smartsheet/widgets/maintenance_section.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaintenanceSection(
      boxName: 'maintenanceRecords',
      title: "🛠 سجلات الصيانة",
    );
  }
}
