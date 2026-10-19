import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/brand_header.dart';
import '../widgets/link_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await ApiService.instance.login(
        userCode: _codeController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: BrandHeader(),
              ),
              const _CampusBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu campus. Tu impacto.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Recicla, suma puntos y construyamos un campus más sostenible.',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Código de usuario',
                      hint: '00001001',
                      controller: _codeController,
                      suffixIcon: Icons.person_outline,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Contraseña',
                      hint: '••••••••••••',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: LinkText(
                        '¿Olvidaste tu contraseña?',
                        onTap: () => Navigator.pushNamed(context, '/recover'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: _loading ? 'Conectando…' : 'Iniciar sesión',
                      onPressed: _loading ? null : _login,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes una cuenta? ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                        LinkText(
                          'Regístrate',
                          onTap: () =>
                              Navigator.pushNamed(context, '/register/email'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'Acceso para la comunidad universitaria',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder de la foto del campus. Reemplazar por Image.asset(...).
class _CampusBanner extends StatelessWidget {
  const _CampusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B7F8E), Color(0xFFA9B8C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF7BD88F),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'CADA ACCIÓN SUMA',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14532D),
          ),
        ),
      ),
    );
  }
}
