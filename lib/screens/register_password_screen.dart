import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/icon_badge.dart';
import '../widgets/register_top_bar.dart';

class RegisterPasswordScreen extends StatefulWidget {
  const RegisterPasswordScreen({super.key});

  @override
  State<RegisterPasswordScreen> createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  bool get _minLength => _pass.text.length >= 8;
  bool get _lettersNumbers =>
      RegExp(r'[A-Za-z]').hasMatch(_pass.text) &&
      RegExp(r'\d').hasMatch(_pass.text);
  bool get _withinApiLimit => utf8.encode(_pass.text).length <= 72;
  bool get _match => _pass.text.isNotEmpty && _pass.text == _confirm.text;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _createAccount(
    String code,
    String name,
    String email,
    String securityToken,
  ) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await ApiService.instance.register(
        userCode: code,
        name: name,
        password: _pass.text,
        email: email,
        securityToken: securityToken,
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
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final registrationData = arguments is Map ? arguments : null;
    final rawCode = registrationData?['cod_user'];
    final rawName = registrationData?['nombre'];
    final rawEmail = registrationData?['correo_institucional'];
    final rawSecurityToken = registrationData?['token_seguridad'];
    final validData =
        rawCode is String &&
        rawName is String &&
        rawEmail is String &&
        rawSecurityToken is String &&
        rawSecurityToken.isNotEmpty;
    final canSubmit =
        _minLength && _lettersNumbers && _match && _withinApiLimit;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegisterTopBar(step: 3),
              const SizedBox(height: 20),
              const IconBadge(icon: Icons.shield_outlined),
              const SizedBox(height: 14),
              Text(
                'Protege tu cuenta',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea una contraseña para terminar tu registro.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TU CÓDIGO DE USUARIO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      validData ? rawCode : 'Código no disponible',
                      style: TextStyle(
                        fontSize: validData ? 22 : 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Guárdalo: lo usarás para iniciar sesión.',
                      style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Crear contraseña',
                hint: '••••••••••••',
                controller: _pass,
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Confirmar contraseña',
                hint: '••••••••••••',
                controller: _confirm,
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _Rule('Al menos 8 caracteres', _minLength),
              _Rule('Incluye letras y números', _lettersNumbers),
              _Rule('Las contraseñas coinciden', _match),
              _Rule('Máximo 72 bytes', _withinApiLimit),
              const SizedBox(height: 14),
              AppButton(
                label: _loading ? 'Creando cuenta…' : 'Crear cuenta',
                onPressed: canSubmit && validData && !_loading
                    ? () => _createAccount(
                        rawCode,
                        rawName,
                        rawEmail,
                        rawSecurityToken,
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Tu contraseña es personal. Nunca la compartas con otras personas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, color: AppColors.textGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String text;
  final bool ok;

  const _Rule(this.text, this.ok);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 13,
            color: ok ? AppColors.green : AppColors.textGrey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: ok ? AppColors.green : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
