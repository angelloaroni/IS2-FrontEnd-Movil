import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/icon_badge.dart';
import '../widgets/info_box.dart';
import '../widgets/register_top_bar.dart';

class RegisterVerifyScreen extends StatelessWidget {
  const RegisterVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final rawCode = arguments is Map ? arguments['cod_user'] : null;
    final rawName = arguments is Map ? arguments['nombre'] : null;
    final data = rawCode is String && rawName is String
        ? {'cod_user': rawCode, 'nombre': rawName}
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
                'Verifica tus datos',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Confirma que el código y el nombre estén correctos antes de crear tu cuenta.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 18),
              if (data == null ||
                  data['cod_user'] == null ||
                  data['nombre'] == null)
                const InfoBox.warning(
                  title: 'No encontramos tus datos',
                  message:
                      'Regresa al paso anterior e ingresa tu nombre y código.',
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
              ],
              const SizedBox(height: 16),
              const InfoBox.warning(
                title: 'Verificación de correo no disponible',
                message: 'El backend actual no ofrece envío ni validación de códigos por correo. Esta pantalla confirma los datos que se enviarán al registrar la cuenta.',
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Continuar',
                onPressed:
                    data == null ||
                        data['cod_user'] == null ||
                        data['nombre'] == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        '/register/password',
                        arguments: data,
                      ),
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
