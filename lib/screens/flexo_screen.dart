import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import 'serial_setup_screen.dart';
import 'ink_report_screen.dart';
import 'store_entry_screen.dart';
import 'maintenance_screen.dart';
import 'calculator_screen.dart';

class FlexoScreen extends StatelessWidget {
  const FlexoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا

      appBar: AppBar(
        centerTitle: true,
        title: const Text("الفلكسو"),
        actions: const [],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SerialSetupScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  const Text("تركيب السيريل", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InkReportScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  const Text("تقرير الأحبار", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoreEntryScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("وارد المخزن", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("الصيانة", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalculatorScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  const Text("الآلة الحاسبة", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
