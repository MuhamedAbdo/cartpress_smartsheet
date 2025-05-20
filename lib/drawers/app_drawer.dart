import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/backup_service.dart';
import '../screens/settings_screen.dart'; // ⬅️ استيراد شاشة الإعدادات

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // تحديد إذا كنا في AboutScreen أو SettingsScreen
    final isInAboutScreen = currentRoute == '/about';
    final isInSettingsScreen = currentRoute == SettingsScreen.routeName;

    return Drawer(
      backgroundColor:
          themeProvider.isDarkTheme ? Colors.grey[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 🖼️ Header مع صورة كبيرة واسم التطبيق تحتها
          DrawerHeader(
            decoration: BoxDecoration(
              color: themeProvider.isDarkTheme
                  ? Colors.blueGrey[800]
                  : Colors.blue,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 🖼️ الصورة - قلل ارتفاعها
                Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 8),

                // 📝 اسم التطبيق تحت الصورة
                const Text(
                  "Cartpress Smartsheet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔧 زر الإعدادات
          if (!isInSettingsScreen)
            ListTile(
              title: const Text("🔧 الإعدادات"),
              trailing: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // ❌ إغلاق الـ drawer
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
            ),

          // 🔐 تسجيل الدخول
          ListTile(
            leading: const Icon(Icons.login, color: Colors.blue),
            title: const Text("تسجيل الدخول"),
            onTap: () {
              Navigator.pop(context); // ❌ إغلاق الـ drawer أولًا
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("ستبدأ هذه الوظيفة عند ربط التطبيق بـ Google Drive"),
                ),
              );
            },
          ),

          // 💾 إنشاء نسخة احتياطية
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.green),
            title: const Text("إنشاء نسخة احتياطية"),
            onTap: () async {
              Navigator.pop(context); // ❌ إغلاق الـ drawer
              await BackupService().createLocalBackup(context);
            },
          ),

          // 🔄 استعادة نسخة احتياطية
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.purple),
            title: const Text("استعادة نسخة احتياطية"),
            onTap: () async {
              Navigator.pop(context); // ❌ إغلاق الـ drawer
              await BackupService().restoreFromLocalBackup(context);
            },
          ),

          const Divider(),

          // ℹ️ حول التطبيق
          if (!isInAboutScreen && !isInSettingsScreen)
            ListTile(
              title: const Text("حول التطبيق"),
              trailing: const Icon(Icons.info),
              onTap: () {
                Navigator.pop(context); // ⬅️ إغلاق الشاشة الجانبية
                Navigator.pushNamed(context, '/about');
              },
            ),
        ],
      ),
    );
  }
}
