import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/custom_loading_indicator.dart';
import '../../../../core/presentation/widgets/error_view.dart';
import '../../../../core/presentation/widgets/repo_card.dart';
import '../../../../core/utils/debouncer.dart';
import '../providers/explore_provider.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _debouncer = Debouncer(400);
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث عن مستودعات...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(exploreProvider.notifier).loadTrending();
              },
            ),
          ),
          onChanged: (value) {
            _debouncer.run(() {
              ref.read(exploreProvider.notifier).search(value);
            });
          },
        ),
      ),
      body: exploreState.when(
        data: (repos) {
          if (repos.isEmpty) {
            return const Center(child: Text('مفيش نتائج للبحث ده.'));
          }
          return ListView.builder(
            itemCount: repos.length,
            itemBuilder: (context, index) {
              return RepoCard(repo: repos[index]);
            },
          );
        },
        loading: () => const CustomLoadingIndicator(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () {
            if (_searchController.text.isEmpty) {
              ref.read(exploreProvider.notifier).loadTrending();
            } else {
              ref.read(exploreProvider.notifier).search(_searchController.text);
            }
          },
        ),
      ),
    );
  }
}