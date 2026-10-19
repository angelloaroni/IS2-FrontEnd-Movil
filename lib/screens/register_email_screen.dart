import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/icon_badge.dart';
import '../widgets/info_box.dart';
import '../widgets/link_text.dart';
import '../widgets/register_top_bar.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_loading) return;
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(code) ||
        name.isEmpty ||
        !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa tu nombre, un código de 8 dígitos y un correo válido.',
          ),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.instance.requestRegistrationCode(email: email);
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/register/verify',
          arguments: {
            'cod_user': code,
            'nombre': name,
            'correo_institucional': email,
          },
        );
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

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegisterTopBar(step: 1),
              const SizedBox(height: 20),
              const IconBadge(icon: Icons.person_add_alt_1_outlined),
              const SizedBox(height: 14),
              Text(
                'Empieza a hacer\nla diferencia.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea tu cuenta de usuario de la Universidad de Lima.',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Nombre completo',
                hint: 'Ana Pérez',
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Correo institucional',
                hint: 'ana@universidad.edu',
                controller: _emailController,
                suffixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Código de usuario (8 dígitos)',
                hint: '00001004',
                controller: _codeController,
                suffixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Usa el código asignado por la Universidad de Lima.',
                style: TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: _loading ? 'Enviando código…' : 'Enviar código',
                icon: Icons.arrow_forward,
                onPressed: _loading ? null : _continue,
              ),
              const SizedBox(height: 14),
              const InfoBox(
                icon: Icons.eco_outlined,
                title: 'Una cuenta, muchas oportunidades',
                message: 'Enviaremos un código de verificación a tu correo institucional. Tu reciclaje se convierte en puntos y podrás consultar tu impacto.',
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Usa tu correo institucional y un código de usuario único de 8 dígitos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: LinkText(
                  '¿Ya tienes cuenta? Inicia sesión',
                  onTap: () => Navigator.popUntil(
                    context,
                    ModalRoute.withName('/login'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
