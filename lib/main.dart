import 'package:flutter/material.dart';
import 'package:four_restaurants/views/login_page.dart';
import 'package:four_restaurants/views/restaurants_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://yjosbkdcerkyhehdjcvg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlqb3Nia2RjZXJreWhlaGRqY3ZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYyNTM3ODgsImV4cCI6MjA1MTgyOTc4OH0.H-_gJq49w4kQkz2YViUZQHN4uME4OLuPasbG2u99vj8',
  );
  await initializeDateFormatting('it_IT', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Four Restaurants",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/restaurants': (context) => const RestaurantsListWidget(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const RestaurantsListWidget();
    } else {
      return const LoginPage();
    }
  }
}
