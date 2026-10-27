import 'package:flutter/material.dart';
import 'package:stargazer_app/features/github/presentation/explore_widgets/person_card.dart';
import 'package:stargazer_app/features/github/presentation/explore_widgets/section_header.dart';

import '../../../../core/theme/app_colors.dart';

class PeopleSection extends StatelessWidget {
  const PeopleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'People to know',
          trailing: GestureDetector(
            onTap: () {},
            child: const Text(
              'See all',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const PersonCard(name: 'shadcn', bio: 'Building things for the web.'),
      ],
    );
  }
}
