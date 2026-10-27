import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/custom_loading_indicator.dart';
import '../../../../core/presentation/widgets/repo_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/saved_widgets/empty_state.dart';
import '../../domain/saved_widgets/header.dart';
import '../providers/saved_repos_provider.dart';

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedState = ref.watch(savedReposProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: savedState.when(
          loading: () => const CustomLoadingIndicator(),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(err.toString(), textAlign: TextAlign.center),
            ),
          ),
          data: (repos) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverToBoxAdapter(child: Header(count: repos.length)),
              ),
              if (repos.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: SliverList.separated(
                    itemCount: repos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final repo = repos[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Dismissible(
                          key: ValueKey(repo.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppColors.surface,
                            ),
                          ),
                          onDismissed: (_) => ref
                              .read(savedReposProvider.notifier)
                              .toggleSave(repo),
                          child: RepoCard(repo: repo),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
