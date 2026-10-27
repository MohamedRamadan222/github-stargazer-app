import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class WeekDropdown extends StatelessWidget {
  const WeekDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'This week',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Icon(
          Icons.keyboard_arrow_down,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
