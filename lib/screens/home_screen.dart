import 'package:flutter/material.dart';
import 'package:cartpress_smartsheet/screens/production_line_screen.dart';
import 'package:cartpress_smartsheet/screens/flexo_screen.dart';
import 'package:cartpress_smartsheet/drawers/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cartpress Smartsheet'),
        // 🔹 تم إزالة زر تبديل الثيم من هنا
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductionLineScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("خط الإنتاج", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlexoScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("الفلكسو", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
