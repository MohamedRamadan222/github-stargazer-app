import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/github_repo.dart';
import '../../../../core/presentation/widgets/custom_loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/details_provider.dart';
import '../providers/saved_repos_provider.dart';

String _compact(int n) {
  final s = n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}m'
      : n >= 1000
      ? '${(n / 1000).toStringAsFixed(1)}k'
      : '$n';
  return s.replaceFirst(RegExp(r'\.0(?=[km])'), '');
}

class RepoDetailsPage extends ConsumerStatefulWidget {
  const RepoDetailsPage({super.key, required this.repo});

  final GithubRepo repo;

  @override
  ConsumerState<RepoDetailsPage> createState() => _RepoDetailsPageState();
}

class _RepoDetailsPageState extends ConsumerState<RepoDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(repoDetailsProvider.notifier)
          .loadAll(widget.repo.owner.login, widget.repo.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repoDetailsProvider);
    final saved = ref.watch(savedReposProvider).value ?? [];
    final isSaved = saved.any((r) => r.id == widget.repo.id);
    final repo = widget.repo;
    final desc = repo.description;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Repository',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: isSaved ? AppColors.primarySoft : AppColors.surface,
              shape: CircleBorder(
                side: BorderSide(
                  color: isSaved ? AppColors.primarySoft : AppColors.border,
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () =>
                    ref.read(savedReposProvider.notifier).toggleSave(repo),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                    color: isSaved ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const CustomLoadingIndicator()
          : state.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.error!, textAlign: TextAlign.center),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${repo.owner.login} /',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    repo.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star_border,
                          value: _compact(repo.stargazersCount),
                          label: 'Stars',
                        ),
                      ),
                      if (state.details != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.visibility_outlined,
                            value: _compact(state.details!.subscribersCount),
                            label: 'Watchers',
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.code,
                          value: repo.language,
                          label: 'Language',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'README',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: state.readme == null
                        ? const Text(
                            'No README available.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          )
                        : MarkdownBody(
                            data: state.readme!,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textPrimary,
                              ),
                              h1: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              h2: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              h3: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              a: const TextStyle(color: AppColors.primary),
                              code: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                backgroundColor: AppColors.primarySoft,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
