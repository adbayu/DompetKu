import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  await initializeDateFormatting('id_ID');
  final appProvider = AppProvider();
  await appProvider.initialize();
  runApp(DompetkuApp(appProvider: appProvider));
}

class DompetkuApp extends StatelessWidget {
  const DompetkuApp({super.key, required this.appProvider});

  final AppProvider appProvider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appProvider,
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dompetku',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
