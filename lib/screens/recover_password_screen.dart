import 'dart:convert';

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

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _email = TextEditingController();
  final _verificationCode = TextEditingController();
  final _userCode = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  int _step = 0;
  bool _loading = false;
  String? _securityToken;

  @override
  void dispose() {
    _email.dispose();
    _verificationCode.dispose();
    _userCode.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  bool get _passwordValid =>
      _password.text.length >= 8 &&
      RegExp(r'[A-Za-z]').hasMatch(_password.text) &&
      RegExp(r'\d').hasMatch(_password.text) &&
      utf8.encode(_password.text).length <= 72;

  Future<void> _requestCode() async {
    if (_loading) return;
    final email = _email.text.trim();
    if (!_isValidEmail(email)) {
      _showMessage('Ingresa un correo institucional válido.');
      return;
    }
    await _run(() async {
      await ApiService.instance.requestPasswordRecoveryCode(email: email);
      if (mounted) setState(() => _step = 1);
      if (mounted) {
        _showMessage(
          'Si el correo está asociado a una cuenta, recibirás un código.',
        );
      }
    });
  }

  Future<void> _verifyCode() async {
    if (_loading) return;
    final code = _verificationCode.text.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(code)) {
      _showMessage('Ingresa el código de 8 dígitos que recibiste.');
      return;
    }
    await _run(() async {
      final token = await ApiService.instance.verifyCode(
        email: _email.text.trim(),
        code: code,
        purpose: 'recuperacion',
      );
      if (mounted) {
        setState(() {
          _securityToken = token;
          _step = 2;
        });
      }
    });
  }

  Future<void> _changePassword() async {
    if (_loading) return;
    final userCode = _userCode.text.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(userCode)) {
      _showMessage('Ingresa tu código de usuario de 8 dígitos.');
      return;
    }
    if (!_passwordValid) {
      _showMessage(
        'La contraseña debe tener 8 caracteres, letras y números, y hasta 72 bytes.',
      );
      return;
    }
    if (_password.text != _confirmPassword.text) {
      _showMessage('Las contraseñas no coinciden.');
      return;
    }
    final token = _securityToken;
    if (token == null) {
      _showMessage('Verifica primero el código enviado a tu correo.');
      return;
    }
    await _run(() async {
      await ApiService.instance.changePassword(
        userCode: userCode,
        password: _password.text,
        securityToken: token,
      );
      if (mounted) setState(() => _step = 3);
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (error) {
      if (mounted) _showMessage('$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final completed = _step == 3;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegisterTopBar(),
              const SizedBox(height: 20),
              IconBadge(
                icon: completed
                    ? Icons.check_circle_outline
                    : Icons.key_outlined,
              ),
              const SizedBox(height: 14),
              Text(
                completed ? 'Contraseña actualizada' : 'Recupera tu acceso',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                completed
                    ? 'Ya puedes iniciar sesión con tu nueva contraseña.'
                    : 'Verificaremos tu correo institucional antes de cambiar la contraseña.',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 18),
              if (_step == 0) ...[
                AppTextField(
                  label: 'Correo institucional',
                  hint: 'ana@universidad.edu',
                  controller: _email,
                  suffixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: _loading ? 'Enviando código…' : 'Enviar código',
                  onPressed: _loading ? null : _requestCode,
                ),
              ] else if (_step == 1) ...[
                const InfoBox(
                  icon: Icons.mark_email_read_outlined,
                  title: 'Revisa tu correo',
                  message: 'Si el correo está asociado a una cuenta activa, recibirás un código de 8 dígitos.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _verificationCode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Código de verificación',
                    hintText: '12345678',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: _loading ? 'Verificando…' : 'Verificar código',
                  onPressed: _loading ? null : _verifyCode,
                ),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : _requestCode,
                    child: const Text('Reenviar código'),
                  ),
                ),
              ] else if (_step == 2) ...[
                AppTextField(
                  label: 'Código de usuario (8 dígitos)',
                  hint: '00001004',
                  controller: _userCode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Nueva contraseña',
                  hint: '••••••••••••',
                  controller: _password,
                  isPassword: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Confirmar contraseña',
                  hint: '••••••••••••',
                  controller: _confirmPassword,
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                Text(
                  'Mínimo 8 caracteres, letras y números; máximo 72 bytes.',
                  style: TextStyle(
                    fontSize: 10,
                    color: _passwordValid
                        ? AppColors.green
                        : AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: _loading ? 'Actualizando…' : 'Cambiar contraseña',
                  onPressed: _loading ? null : _changePassword,
                ),
              ] else ...[
                const InfoBox(
                  icon: Icons.check_circle_outline,
                  title: 'Cambio realizado',
                  message: 'Tu contraseña se actualizó correctamente.',
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Volver a iniciar sesión',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              if (!completed) ...[
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'El código vence en 3 minutos y admite hasta 5 intentos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5, color: AppColors.textGrey),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (!completed)
                Center(
                  child: LinkText(
                    'Volver a iniciar sesión',
                    onTap: () => Navigator.maybePop(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
