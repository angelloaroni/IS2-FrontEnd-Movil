import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/icon_badge.dart';
import '../widgets/info_box.dart';
import '../widgets/link_text.dart';
import '../widgets/register_top_bar.dart';

class RecoverPasswordScreen extends StatelessWidget {
  const RecoverPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegisterTopBar(),
              const SizedBox(height: 20),
              const IconBadge(icon: Icons.key_outlined),
              const SizedBox(height: 14),
              Text(
                'Recupera tu acceso',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'La API actual no incluye un servicio para solicitar el cambio de contraseña.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 18),
              const SizedBox(height: 18),
              const AppButton(
                label: 'Recuperación no disponible',
                onPressed: null,
              ),
              const SizedBox(height: 14),
              const InfoBox.warning(
                title: 'Función pendiente en el backend',
                message: 'La guía de la API no documenta recuperación por correo. Contacta al administrador para restablecer tu cuenta.',
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'Por seguridad, no compartas el enlace de recuperación con nadie.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 10),
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
