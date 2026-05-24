import 'package:flutter/material.dart';
import 'package:spotify_with_flutter/core/routes/app_routes.dart';
import 'package:spotify_with_flutter/core/configs/theme/app_theme.dart';
import 'package:spotify_with_flutter/core/services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        ),
    );
  }
}
