import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.bookmark_border, color: AppColors.primary),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Nothing saved yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Repositories you save will show up here, even offline.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
