import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/domain/entities/github_repo.dart';
import '../../../../core/presentation/widgets/custom_loading_indicator.dart';
import '../providers/details_provider.dart';
import '../providers/saved_repos_provider.dart';

class RepoDetailsPage extends ConsumerStatefulWidget {
  final GithubRepo repo;
  const RepoDetailsPage({super.key, required this.repo});

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
    final detailsState = ref.watch(repoDetailsProvider);
    final savedRepos = ref.watch(savedReposProvider).value ?? [];
    final isSaved = savedRepos.any((r) => r.id == widget.repo.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.repo.name),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.blue : null,
            ),
            onPressed: () =>
                ref.read(savedReposProvider.notifier).toggleSave(widget.repo),
          ),
        ],
      ),
      body: detailsState.isLoading
          ? const CustomLoadingIndicator()
          : detailsState.error != null
          ? Center(child: Text(detailsState.error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBadge(
                        icon: Icons.star,
                        label: '${widget.repo.stargazersCount} Stars',
                      ),
                      if (detailsState.details != null)
                        _StatBadge(
                          icon: Icons.visibility,
                          label:
                              '${detailsState.details!.subscribersCount} Watchers',
                        ),
                      _StatBadge(icon: Icons.code, label: widget.repo.language),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'README.md',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (detailsState.readme != null)
                    MarkdownBody(data: detailsState.readme!),
                ],
              ),
            ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon, size: 18), const SizedBox(width: 4), Text(label)],
    );
  }
}
