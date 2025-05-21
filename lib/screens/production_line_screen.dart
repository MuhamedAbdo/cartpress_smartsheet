import 'package:cartpress_smartsheet/screens/maintenance_screen.dart';
import 'package:cartpress_smartsheet/screens/workers_screen.dart';
import 'package:cartpress_smartsheet/widgets/maintenance_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:cartpress_smartsheet/theme_provider.dart';
import 'package:cartpress_smartsheet/screens/sheet_size_screen.dart';
import 'package:cartpress_smartsheet/screens/sheet_count_screen.dart';
import 'package:cartpress_smartsheet/screens/calculator_screen.dart';
import 'package:cartpress_smartsheet/screens/saved_sheet_sizes_screen.dart';

class ProductionLineScreen extends StatelessWidget {
  const ProductionLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا
      appBar: AppBar(
        centerTitle: true,
        title: const Text("خط الإنتاج"),
        actions: const [
          // ❌ إزالة زر تبديل الثيم من هنا (لن يكون في الـ AppBar)
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SheetSizeScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("مقاس الشيت", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SheetCountScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("عدد الشيتات", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceSection(
                    boxName: 'production_maintenance',
                    title: "🛠 صيانة خط الإنتاج",
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "الصيانة",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SavedSheetSizesScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("المقاسات المحفوظة",
                  style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WorkersScreen(
                    departmentBoxName: 'production_workers',
                    departmentTitle: "خط الإنتاج",
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "👷‍♂️ طاقم العمل",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
