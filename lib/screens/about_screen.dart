// about_screen.dart
import 'package:cartpress_smartsheet/constants/terms.dart';
import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:cartpress_smartsheet/screens/terms_and_policy_screen.dart';
import 'package:cartpress_smartsheet/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا

      appBar: AppBar(
        centerTitle: true,
        title: const Text("ℹ️ حول التطبيق"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 🏷️ اسم التطبيق
            Text(
              "CartPress Smartsheet",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "نسخة تجريبية - v1.0.0+1",
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 14,
              ),
            ),
            const Divider(height: 32),

            // 📝 الوصف
            Text(
              "الوصف:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            // ignore: prefer_const_constructors
            Text(
              "تطبيق لمساعدة عمال الطباعة والكرتون على حفظ المقاسات وتقارير الأحبار بسهولة مع دعم البحث، الصور، والطباعة.",
              style: const TextStyle(fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),

            // 👤 المطور
            Text(
              "المطور:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                ),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Mohamed Abdelaal\n"),
                      TextSpan(text: '📞 الاتصال: +201148578813\n'),
                      TextSpan(
                        text:
                            '📧 البريد الإلكتروني: mohamedabdo9999933@gmail.com',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🌐 الروابط (اختياري)
            Text(
              "روابط مهمة:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndPolicyScreen(
                      title: "شروط الاستخدام",
                      content: termsOfUseText,
                    ),
                  ),
                );
              },
              child: const Text(
                "- شروط الاستخدام",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndPolicyScreen(
                      title: "سياسة الخصوصية",
                      content: privacyPolicyText,
                    ),
                  ),
                );
              },
              child: const Text(
                "- سياسة الخصوصية",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 24),

            // 📄 نسخة APK
            Text(
              "الإصدار:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Build: \nSDK: Flutter 3.x.x\nAndroid API: 34\niOS Deployment Target: 14.0",
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : Colors.black54),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),

            const Spacer(),

            // 💡 رسالة ثابتة
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "© 2025 CartPress Inc.\nAll rights reserved.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
