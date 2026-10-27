import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.hub_outlined, size: 28, color: AppColors.textPrimary),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Explore',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.tune, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
