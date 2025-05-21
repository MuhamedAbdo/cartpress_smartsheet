import 'package:cartpress_smartsheet/screens/about_screen.dart';
import 'package:cartpress_smartsheet/screens/camera_quality_settings_screen.dart';
import 'package:cartpress_smartsheet/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Models
import 'models/worker_model.dart';
import 'models/worker_action_model.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/flexo_screen.dart';
import 'screens/ink_report_screen.dart';
import 'screens/store_entry_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/sheet_size_screen.dart';
import 'screens/saved_sheet_sizes_screen.dart';
import 'screens/serial_setup_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/workers_screen.dart'; // تأكد من إضافة هذا الاستيراد

// Providers
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Hive مع معالجة الأخطاء
  try {
    await Hive.initFlutter();

    // تسجيل Adapters
    Hive.registerAdapter(WorkerAdapter());
    Hive.registerAdapter(WorkerActionAdapter());

    // فتح جميع الصناديق مع التحقق من الأخطاء
    await Future.wait([
      Hive.openBox('settings'),
      Hive.openBox('inkReports'),
      Hive.openBox('storeEntries'),
      Hive.openBox('maintenanceRecords'),
      Hive.openBox('savedSheetSizes'),
      Hive.openBox('serialSetupState'),
      Hive.openBox<Worker>('workers_section_production'),
      Hive.openBox<Worker>('workers_section_flexo'),
      Hive.openBox<Worker>('workers_section_store'),
      Hive.openBox<WorkerAction>('worker_actions'),
    ]);

    print('تم فتح جميع صناديق Hive بنجاح');
  } catch (e) {
    print('حدث خطأ أثناء تهيئة Hive: $e');
    // يمكنك إضافة إجراءات إضافية هنا مثل إعادة المحاولة
  }

  runApp(const CartpressSmartSheet());
}

class CartpressSmartSheet extends StatelessWidget {
  const CartpressSmartSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cartpress Smartsheet',
      theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: const HomeScreen(),
      routes: {
        '/flexo': (_) => const FlexoScreen(),
        '/inkReport': (_) => const InkReportScreen(),
        '/storeEntry': (_) => const StoreEntryScreen(),
        '/maintenance': (_) => const MaintenanceScreen(),
        '/sheetSize': (_) => const SheetSizeScreen(),
        '/savedSheetSizes': (_) => const SavedSheetSizesScreen(),
        '/serialSetup': (_) => const SerialSetupScreen(),
        '/calculator': (_) => const CalculatorScreen(),
        '/about': (_) => const AboutScreen(),
        '/workers': (_) => const WorkersScreen(
              // أضف هذا المسار
              departmentBoxName: 'workers_section_production',
              departmentTitle: 'الإنتاج',
            ),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        CameraQualitySettingsScreen.routeName: (_) =>
            const CameraQualitySettingsScreen(),
      },
    );
  }
}
