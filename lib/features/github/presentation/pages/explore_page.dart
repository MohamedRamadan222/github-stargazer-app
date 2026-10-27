import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/presentation/widgets/custom_loading_indicator.dart';
import '../../../../core/presentation/widgets/rate_limit_widget.dart';
import '../../../../core/presentation/widgets/repo_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/debouncer.dart';
import '../explore_widgets/filter_chip.dart';
import '../explore_widgets/footer.dart';
import '../explore_widgets/header.dart';
import '../explore_widgets/hero.dart';
import '../explore_widgets/people_section.dart';
import '../explore_widgets/search_field.dart';
import '../explore_widgets/section_header.dart';
import '../explore_widgets/week_drop_down.dart';
import '../providers/explore_provider.dart';

enum _Filter { all, repositories, people }

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _debouncer = Debouncer(400);
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(exploreProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clear() {
    _searchController.clear();
    setState(() {});
    ref.read(exploreProvider.notifier).loadTrending();
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreProvider);
    final isFetchingMore = ref.watch(exploreProvider.notifier).isFetchingMore;
    final isIdle = _searchController.text.isEmpty;
    final showRepos = _filter != _Filter.people;
    final showPeople = isIdle && _filter != _Filter.repositories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Header(),
                    const SizedBox(height: 20),
                    SearchField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                        _debouncer.run(
                          () =>
                              ref.read(exploreProvider.notifier).search(value),
                        );
                      },
                      onClear: _clear,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (f, label) in [
                          (_Filter.all, 'All'),
                          (_Filter.repositories, 'Repositories'),
                          (_Filter.people, 'People'),
                        ])
                          FilterChipe(
                            label: label,
                            selected: _filter == f,
                            onTap: () => setState(() => _filter = f),
                          ),
                      ],
                    ),
                    if (isIdle) ...[const SizedBox(height: 28), const Heroo()],
                    if (showRepos) ...[
                      const SizedBox(height: 28),
                      SectionHeader(
                        title: isIdle ? 'Trending repositories' : 'Results',
                        trailing: isIdle ? const WeekDropdown() : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            if (showRepos)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: exploreState.when(
                  data: (repos) {
                    if (repos.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text('No results found.')),
                        ),
                      );
                    }
                    return SliverList.separated(
                      itemCount: repos.length + (isFetchingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == repos.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CustomLoadingIndicator(),
                          );
                        }
                        return RepoCard(repo: repos[index]);
                      },
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CustomLoadingIndicator(),
                    ),
                  ),
                  error: (error, stack) {
                    if (error is RateLimitFailure) {
                      return SliverToBoxAdapter(
                        child: RateLimitWidget(
                          resetTime: error.resetTime,
                          onRetry: () =>
                              ref.read(exploreProvider.notifier).loadTrending(),
                        ),
                      );
                    }
                    final message = error is Failure
                        ? error.message
                        : error.toString();
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text(message)),
                      ),
                    );
                  },
                ),
              ),
            if (showPeople)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
                sliver: SliverToBoxAdapter(child: PeopleSection()),
              ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
              sliver: SliverToBoxAdapter(child: Footer()),
            ),
          ],
        ),
      ),
    );
  }
}
