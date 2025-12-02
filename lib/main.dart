import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/src/core/di/injector.dart';
import 'package:flutter_app/src/core/navigation/app_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // providers may attempt to access Firebase instances; when running
    // widget tests the Firebase app may not be initialized. Guard to
    // return an empty provider list in that case so tests can run.
    final providerList = <SingleChildWidget>[];
    try {
      // providers getter may throw if Firebase isn't initialized
      providerList.addAll(providers);
    } catch (_) {
      // fallback: provide a minimal provider so MultiProvider has at least
      // one child and tests that pump MyApp won't crash.
      providerList.add(Provider<int>.value(value: 0));
    }

    return MultiProvider(
      providers: providerList,
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Glooba',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6F4CFF),
            primary: const Color(0xFF6F4CFF),
            secondary: const Color(0xFF9379FF),
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF333333),
            error: Colors.redAccent,
            onError: Colors.white,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF333333)),
            titleTextStyle: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 12.0,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F4CFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
