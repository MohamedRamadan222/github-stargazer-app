import 'package:flutter/material.dart';
import 'package:stargazer_app/features/github/presentation/profile_widgets/state.dart';

import '../../../../core/theme/app_colors.dart';

String _compact(int n) {
  final s = n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}m'
      : n >= 1000
      ? '${(n / 1000).toStringAsFixed(1)}k'
      : '$n';
  return s.replaceFirst(RegExp(r'\.0(?=[km])'), '');
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.login,
    required this.bio,
    required this.followers,
    required this.following,
  });

  final String avatarUrl;
  final String name;
  final String login;
  final String? bio;
  final int followers;
  final int following;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.dark,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '@$login',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.code, size: 18, color: AppColors.primary),
              ),
            ),
          ],
        ),
        if (bio != null && bio!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            bio!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            Stat(value: _compact(followers), label: 'followers'),
            Stat(value: _compact(following), label: 'following'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Follow'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primarySoft,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(Icons.share_outlined, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
