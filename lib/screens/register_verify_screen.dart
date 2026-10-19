import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/icon_badge.dart';
import '../widgets/info_box.dart';
import '../widgets/register_top_bar.dart';

class RegisterVerifyScreen extends StatefulWidget {
  const RegisterVerifyScreen({super.key});

  @override
  State<RegisterVerifyScreen> createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends State<RegisterVerifyScreen> {
  final _verificationCode = TextEditingController();
  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    _verificationCode.dispose();
    super.dispose();
  }

  Future<void> _verify(Map<String, String> data) async {
    if (_loading) return;
    final code = _verificationCode.text.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(code)) {
      _showMessage('Ingresa el código de 8 dígitos que recibiste.');
      return;
    }
    setState(() => _loading = true);
    try {
      final securityToken = await ApiService.instance.verifyCode(
        email: data['correo_institucional']!,
        code: code,
        purpose: 'registro',
      );
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/register/password',
          arguments: {...data, 'token_seguridad': securityToken},
        );
      }
    } catch (error) {
      if (mounted) _showMessage('$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend(Map<String, String> data) async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      await ApiService.instance.requestRegistrationCode(
        email: data['correo_institucional']!,
      );
      if (mounted) _showMessage('Enviamos un nuevo código a tu correo.');
    } catch (error) {
      if (mounted) _showMessage('$error');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final rawCode = arguments is Map ? arguments['cod_user'] : null;
    final rawName = arguments is Map ? arguments['nombre'] : null;
    final rawEmail = arguments is Map
        ? arguments['correo_institucional']
        : null;
    final data = rawCode is String && rawName is String && rawEmail is String
        ? {
            'cod_user': rawCode,
            'nombre': rawName,
            'correo_institucional': rawEmail,
          }
        : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegisterTopBar(step: 2),
              const SizedBox(height: 20),
              const IconBadge(icon: Icons.fact_check_outlined),
              const SizedBox(height: 14),
              Text(
                'Verifica tu correo',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa el código de 8 dígitos enviado a tu correo institucional.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 18),
              if (data == null)
                const InfoBox.warning(
                  title: 'No encontramos tus datos',
                  message: 'Regresa al paso anterior y completa tus datos.',
                )
              else ...[
                _ConfirmationTile(
                  label: 'Nombre completo',
                  value: data['nombre']!,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 10),
                _ConfirmationTile(
                  label: 'Código de usuario',
                  value: data['cod_user']!,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 10),
                _ConfirmationTile(
                  label: 'Correo institucional',
                  value: data['correo_institucional']!,
                  icon: Icons.email_outlined,
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _resending ? null : () => _resend(data),
                  child: Text(_resending ? 'Enviando…' : 'Reenviar código'),
                ),
              ],
              const SizedBox(height: 18),
              AppButton(
                label: _loading ? 'Verificando…' : 'Verificar correo',
                onPressed: data == null || _loading
                    ? null
                    : () => _verify(data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ConfirmationTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
