import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './services/supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    // Remove this block - SupabaseService.initialize() doesn't exist
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
  }

  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization failed: $e');
    // Continue app execution but with limited functionality
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(1.0),
        ),
        child: MaterialApp(
          title: 'PanchakarmaFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.initial,
          routes: AppRoutes.routes,
        ),
      );
    });
  }
}