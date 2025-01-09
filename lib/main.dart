import 'package:flutter/material.dart';
import 'package:four_restaurants/views/login_page.dart';
import 'package:four_restaurants/views/restaurants_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_KEY'),
  );
  await initializeDateFormatting('it_IT', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Colors.blue;

    return MaterialApp(
      title: "Four Restaurants",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
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
