import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Local imports
import 'camera_quality_settings_screen.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("🔧 الإعدادات"),
      ),
      body: ListView(
        children: [
          // 🌓 تبديل الثيم - تم إضافته هنا
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(
              themeProvider.isDarkTheme ? 'الوضع النهاري' : 'الوضع الليلي',
              style: TextStyle(
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            subtitle: const Text("تفعيل أو تعطيل الوضع الليلي"),
            trailing: Switch(
              value: themeProvider.isDarkTheme,
              onChanged: (value) => themeProvider.toggleTheme(),
              activeTrackColor: Colors.grey[700],
              activeColor: Colors.orange,
            ),
            onTap: () {},
          ),
          const Divider(),

          // 📸 جودة الكاميرا
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("جودة الكاميرا"),
            subtitle: const Text("اختر مستوى الجودة المناسب للصور"),
            onTap: () {
              Navigator.pushNamed(
                  context, CameraQualitySettingsScreen.routeName);
            },
          ),

          const Divider(),

          // يمكنك إضافة المزيد من الخيارات لاحقًا هنا
        ],
      ),
    );
  }
}

// ⚙️ زر تبديل الثيم (اختياري - يمكن دمجه مباشرة في الـ ListTile)
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Switch(
      value: themeProvider.isDarkTheme,
      onChanged: (value) => themeProvider.toggleTheme(),
      activeTrackColor: Colors.grey[700],
      activeColor: Colors.orange,
    );
  }
}
