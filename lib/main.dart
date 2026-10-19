import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/recover_password_screen.dart';
import 'screens/register_email_screen.dart';
import 'screens/register_password_screen.dart';
import 'screens/register_verify_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSession = await ApiService.instance.restoreSession();
  runApp(UlimaReciclaApp(initialRoute: hasSession ? '/home' : '/login'));
}

class UlimaReciclaApp extends StatelessWidget {
  final String initialRoute;

  const UlimaReciclaApp({super.key, this.initialRoute = '/login'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ULima Recicla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register/email': (_) => const RegisterEmailScreen(),
        '/register/verify': (_) => const RegisterVerifyScreen(),
        '/register/password': (_) => const RegisterPasswordScreen(),
        '/recover': (_) => const RecoverPasswordScreen(),
        '/home': (_) => const HomeShell(),
      },
    );
  }
}
