import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/core/network/dio_client.dart';
import 'package:stargazer_app/features/github/data/datasources/explore_remote_datasource.dart';
import 'package:stargazer_app/features/github/data/repositories/explore_repository_impl.dart';

import '../../domain/usecases/get_trending_repos_usecase.dart';
import '../../domain/usecases/search_repos_usecase.dart';

// حقن الاساسبات
final dioClintProvider = Provider((ref) => DioClient());
final exploreDatasourceProvider = Provider(
  (ref) => ExploreRemoteDatasourceImpl(dioClient: ref.watch(dioClintProvider)),
);
final exploreRepositoryProvider = Provider(
  (ref) => ExploreRepositoryImpl(ref.watch(exploreDatasourceProvider)),
);

// use cases
final getTrendingUseCaseProvider = Provider(
  (ref) => GetTrendingReposUseCase(ref.watch(exploreRepositoryProvider)),
);
final searchReposUseCaseProvider = Provider(
  (ref) => SearchReposUseCase(ref.watch(exploreRepositoryProvider)),
);

// مدير الحالة
class ExploreNotifier extends StateNotifier<AsyncValue<List<GithubRepo>>> {
  final GetTrendingReposUseCase _getTrending;
  final SearchReposUseCase _searchRepos;
  CancelToken? _cancelToken;

  ExploreNotifier(this._getTrending, this._searchRepos)
    : super(const AsyncValue.loading()) {
    loadTrending();
  }

  Future<void> loadTrending() async {
    state = const AsyncValue.loading();
    final result = await _getTrending();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (repos) => state = AsyncValue.data(repos),
    );
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      return loadTrending();
    }

    state = const AsyncValue.loading();

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final result = await _searchRepos(query, cancelToken: _cancelToken);

    result.fold((failure) {
      if (failure.message != 'تم إلغاء الطلب') {
        state = AsyncValue.error(failure.message, StackTrace.current);
      }
    }, (repos) => state = AsyncValue.data(repos));
  }
}

final exploreProvider =
    StateNotifierProvider<ExploreNotifier, AsyncValue<List<GithubRepo>>>((ref) {
      return ExploreNotifier(
        ref.watch(getTrendingUseCaseProvider),
        ref.watch(searchReposUseCaseProvider),
      );
    });
