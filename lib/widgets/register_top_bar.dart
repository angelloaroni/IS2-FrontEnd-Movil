import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra superior de registro/recuperación: flecha atrás + "ULima Recicla".
/// Si [step] != null muestra el progreso "PASO X DE N".
class RegisterTopBar extends StatelessWidget {
  final int? step;
  final int totalSteps;

  const RegisterTopBar({super.key, this.step, this.totalSteps = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            const Text(
              'ULima Recicla',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        if (step != null) ...[
          const SizedBox(height: 14),
          Text(
            'REGISTRO · PASO $step DE $totalSteps',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(totalSteps, (i) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: i < step! ? AppColors.orange : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
