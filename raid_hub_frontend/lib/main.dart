import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Add gestures import
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add flutter_dotenv
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'screens/landing_screen.dart'; // Import LandingScreen

// Custom ScrollBehavior to allow mouse dragging on web/desktop
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

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

  static const double _compactWidthBreakpoint = 512;

  double _compactScale(double width) {
    if (width >= _compactWidthBreakpoint) {
      return 1.0;
    }

    // Keep a sensible lower bound so very small devices remain usable.
    return (width / _compactWidthBreakpoint).clamp(0.78, 1.0);
  }

  ThemeData _scaledTheme(ThemeData base, double scale) {
    if (scale >= 1.0) {
      return base;
    }

    final densityDelta = ((1.0 - scale) * 4).clamp(0.0, 1.2);

    return base.copyWith(
      textTheme: base.textTheme.apply(fontSizeFactor: scale),
      primaryTextTheme: base.primaryTextTheme.apply(fontSizeFactor: scale),
      visualDensity: VisualDensity(
        horizontal: -densityDelta,
        vertical: -densityDelta,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      iconTheme: base.iconTheme.copyWith(
        size: (base.iconTheme.size ?? 24) * scale,
      ),
      primaryIconTheme: base.primaryIconTheme.copyWith(
        size: (base.primaryIconTheme.size ?? 24) * scale,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Lost Ark Raid Hub',
      scrollBehavior: AppScrollBehavior(), // Apply custom scroll behavior
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
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        final media = MediaQuery.of(context);
        final scale = _compactScale(media.size.width);

        if (scale >= 1.0) {
          return child;
        }

        final compactTheme = _scaledTheme(Theme.of(context), scale);

        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(scale)),
          child: Theme(
            data: compactTheme,
            child: child,
          ),
        );
      },
      home: const LandingScreen(), // Start with LandingScreen
    );
  }
}
