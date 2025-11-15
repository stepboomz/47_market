import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/providers/theme_provider.dart';
import 'package:brand_store_app/resources/app_data.dart';
import 'package:brand_store_app/screens/auth/auth_gate.dart';
import 'package:brand_store_app/screens/auth/login_screen.dart';
import 'package:brand_store_app/screens/auth/reset_password_screen.dart';
import 'package:brand_store_app/screens/auth/signup_screen.dart';
import 'package:brand_store_app/screens/cart.dart';
import 'package:brand_store_app/screens/checkout.dart';
import 'package:brand_store_app/screens/details.dart';
import 'package:brand_store_app/screens/favorites_screen.dart';
import 'package:brand_store_app/screens/main_screen.dart';
import 'package:brand_store_app/screens/onboarding.dart';
import 'package:brand_store_app/screens/settings_screen.dart';
import 'package:brand_store_app/screens/admin_screen.dart';
import 'package:brand_store_app/screens/order_success.dart';
import 'package:brand_store_app/screens/order_history_screen.dart';
import 'package:brand_store_app/screens/e_receipt_screen.dart';
import 'package:brand_store_app/screens/edit_profile_screen.dart';
import 'package:brand_store_app/widgets/ipad_frame.dart';
import 'package:brand_store_app/config/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  // await GoogleFonts.pendingFonts([
  //   GoogleFonts.chakraPetch(),
  //   GoogleFonts.notoSansThai(), // Add Thai font support
  // ]);

  // โหลดข้อมูลจาก JSON (จะใช้เป็น fallback)
  await AppData.loadAllData();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, ref) {
    return ShadApp(
      title: '47 Market',
      themeMode: ref.watch(themeModeProvider),
      theme: ShadThemeData(
          colorScheme: const ShadRedColorScheme.light(),
          brightness: Brightness.light),
      darkTheme: ShadThemeData(
          colorScheme: const ShadRedColorScheme.dark(),
          brightness: Brightness.dark),
      routes: {
        '/main': (context) => const MainScreen(),
        '/admin': (context) => const AdminScreen(),
        '/order-success': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return OrderSuccessScreen(
            orderNumber: args['orderNumber'],
            totalAmount: args['totalAmount'],
          );
        },
        '/cart': (context) => const Cart(),
        '/settings': (context) => const SettingsScreen(),
        'checkout': (context) => const Checkout(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/auth-gate': (context) => const AuthGate(),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/e-receipt': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return EReceiptScreen(order: args);
        },
        '/edit-profile': (context) => const EditProfileScreen(),
      },
      initialRoute: '/MainScreen',
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final args = settings.arguments as Map<String, dynamic>;
          final String tagPrefix = args['prefix'];
          final ShirtModel shirt = args['shirt'];
          return MaterialPageRoute(
            builder: (context) => Details(
              shirt: shirt,
              tagPrefix: tagPrefix,
            ),
          );
        } else if (settings.name == '/cart') {
          return MaterialPageRoute(
            builder: (context) => const Cart(),
          );
        } else if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          );
        } else if (settings.name == '/checkout') {
          return MaterialPageRoute(
            settings: settings, // Preserve settings including arguments
            builder: (context) => const Checkout(),
          );
        } else if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        } else if (settings.name == '/signup') {
          return MaterialPageRoute(
            builder: (context) => const SignupScreen(),
          );
        } else if (settings.name == '/reset-password') {
          return MaterialPageRoute(
            builder: (context) => const ResetPasswordScreen(),
          );
        } else if (settings.name == '/main') {
          return MaterialPageRoute(
            builder: (context) => const MainScreen(),
          );
        } else if (settings.name == '/onboarding') {
          return MaterialPageRoute(
            builder: (context) => const Onboarding(),
          );
        } else if (settings.name == '/auth-gate') {
          return MaterialPageRoute(
            builder: (context) => const AuthGate(),
          );
        } else if (settings.name == '/favorites') {
          return MaterialPageRoute(
            builder: (context) => const FavoritesScreen(),
          );
        } else if (settings.name == '/order-history') {
          return MaterialPageRoute(
            builder: (context) => const OrderHistoryScreen(),
          );
        } else if (settings.name == '/e-receipt') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EReceiptScreen(order: args),
          );
        } else if (settings.name == '/edit-profile') {
          return MaterialPageRoute(
            builder: (context) => const EditProfileScreen(),
          );
        }
        // Default fallback route
        return MaterialPageRoute(
          builder: (context) => const MainScreen(),
        );
      },
      home: const MainScreen(),
      builder: (context, child) {
        // Wrap with iPad frame on desktop and add snow fall animation
        if (child != null) {
          return Stack(
            children: [
              iPadFrame(child: child),
              // Snow fall animation overlay (non-interactive)
              IgnorePointer(
                child: SnowFallAnimation(
                  config: SnowfallConfig(
                    numberOfSnowflakes: 50,
                    speed: 1.0,
                    useEmoji: true,
                    customEmojis: ['❄️', '❅', '❆'],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
