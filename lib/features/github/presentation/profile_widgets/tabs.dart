import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class Tabs extends StatelessWidget {
  const Tabs({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.reposCount,
    required this.starsCount,
  });

  final int selected;
  final ValueChanged<int> onChanged;
  final int reposCount;
  final int starsCount;

  @override
  Widget build(BuildContext context) {
    final items = <(String, int?)>[
      ('Overview', null),
      ('Repositories', reposCount),
      ('Stars', starsCount),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: items[i].$1,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: selected == i
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if (items[i].$2 != null)
                              TextSpan(
                                text: ' ${items[i].$2}',
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      height: 2,
                      color: selected == i
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
