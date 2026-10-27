import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, size: 14, color: AppColors.accentPurple),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'A small window into a world of open source.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ),
      ],
    );
  }
}
