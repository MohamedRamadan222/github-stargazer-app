import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class Heroo extends StatelessWidget {
  const Heroo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.explore_outlined, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Good things start with curiosity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Find your next idea, project, or collaborator.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
