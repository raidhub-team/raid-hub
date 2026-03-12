import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add flutter_dotenv
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'screens/landing_screen.dart'; // Import LandingScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Initialize dotenv
  
  final authService = AuthService();
  await authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const RaidHubApp(),
    ),
  );
}

class RaidHubApp extends StatelessWidget {
  const RaidHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Lost Ark Raid Hub',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      home: const LandingScreen(), // Start with LandingScreen
    );
  }
}
