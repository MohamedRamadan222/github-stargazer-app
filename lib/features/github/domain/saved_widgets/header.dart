import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.bookmark_border,
          size: 28,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Saved',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (count > 0)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
