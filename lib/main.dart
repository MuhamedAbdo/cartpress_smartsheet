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

// Providers
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // افتح الصناديق المطلوبة أولًا
  await Hive.openBox<WorkerAction>('worker_actions'); // ← مهم جدًا

  // سجل الـ Adapters أولًا
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(WorkerAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(WorkerActionAdapter());
  }

  // افتح صناديق البيانات الأساسية
  await Hive.openBox('settings');
  await Hive.openBox('inkReports');
  await Hive.openBox('storeEntries');
  await Hive.openBox('maintenanceRecords');
  await Hive.openBox('savedSheetSizes');
  await Hive.openBox('serialSetupState');

  // افتح صناديق العمال
  await Hive.openBox<Worker>('production_workers');
  await Hive.openBox<Worker>('flexo_workers');
  await Hive.openBox<Worker>('store_workers');
  await Hive.openBox<WorkerAction>('worker_actions');

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
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        CameraQualitySettingsScreen.routeName: (_) =>
            const CameraQualitySettingsScreen(),
      },
    );
  }
}
