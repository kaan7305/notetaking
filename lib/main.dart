import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/widgets/offline_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On web, use the FFI-web factory backed by sqflite_sw.js + sqlite3.wasm.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: StudyNotebookApp()));
}

class StudyNotebookApp extends ConsumerWidget {
  const StudyNotebookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'StudyNotebook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      // Wrap the entire navigator in the global offline banner so it appears
      // on every screen without any per-screen boilerplate.
      builder: (context, child) =>
          OfflineBanner(child: child ?? const SizedBox()),
    );
  }
}
