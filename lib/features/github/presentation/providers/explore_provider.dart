import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/core/network/dio_client.dart';
import 'package:stargazer_app/features/github/data/datasources/explore_remote_datasource.dart';
import 'package:stargazer_app/features/github/data/repositories/explore_repository_impl.dart';

import '../../../../core/error/failures.dart';
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
// مدير الحالة
class ExploreNotifier extends StateNotifier<AsyncValue<List<GithubRepo>>> {
  final GetTrendingReposUseCase _getTrending;
  final SearchReposUseCase _searchRepos;
  CancelToken? _cancelToken;

  // متغيرات التمرير اللانهائي
  int _page = 1;
  bool isFetchingMore = false; // خليناها public عشان نقراها في الـ UI
  bool _hasMore = true;
  String _currentQuery = '';

  ExploreNotifier(this._getTrending, this._searchRepos)
    : super(const AsyncValue.loading()) {
    loadTrending();
  }

  Future<void> loadTrending() async {
    _resetPagination();
    state = const AsyncValue.loading();
    // هنمرر رقم الصفحة هنا
    final result = await _getTrending(page: _page);
    _handleResult(result);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return loadTrending();

    _resetPagination();
    _currentQuery = query;
    state = const AsyncValue.loading();

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    // هنمرر رقم الصفحة هنا
    final result = await _searchRepos(
      query,
      page: _page,
      cancelToken: _cancelToken,
    );
    _handleResult(result);
  }

  // الدالة الجديدة لجلب الصفحة التالية
  Future<void> loadNextPage() async {
    // لو بنحمل حالياً، أو مفيش بيانات تاني، أو في خطأ، متعملش حاجة
    if (isFetchingMore || !_hasMore || state is AsyncLoading || state.hasError)
      return;

    isFetchingMore = true;
    _page++;

    // بنبلغ الواجهة إننا بنحمل عشان تعرض مؤشر التحميل الصغير تحت
    state = AsyncValue.data(state.value ?? []);

    final result = _currentQuery.isEmpty
        ? await _getTrending(page: _page)
        : await _searchRepos(
            _currentQuery,
            page: _page,
            cancelToken: _cancelToken,
          );

    result.fold(
      (failure) {
        _page--; // نرجع خطوة لو حصل خطأ
        isFetchingMore = false;
        state = AsyncValue.data(
          state.value ?? [],
        ); // نحدث الواجهة عشان تخفي المؤشر
      },
      (newRepos) {
        if (newRepos.isEmpty) _hasMore = false;
        isFetchingMore = false;
        // بندمج البيانات القديمة مع الجديدة
        state = AsyncValue.data([...state.value ?? [], ...newRepos]);
      },
    );
  }

  void _resetPagination() {
    _page = 1;
    isFetchingMore = false;
    _hasMore = true;
    _currentQuery = '';
  }

  void _handleResult(Either<Failure, List<GithubRepo>> result) {
    result.fold(
      (failure) {
        if (failure.message != 'تم إلغاء الطلب') {
          state = AsyncValue.error(failure, StackTrace.current);
        }
      },
      (repos) {
        _hasMore = repos.isNotEmpty;
        state = AsyncValue.data(repos);
      },
    );
  }
}

final exploreProvider =
    StateNotifierProvider<ExploreNotifier, AsyncValue<List<GithubRepo>>>((ref) {
      return ExploreNotifier(
        ref.watch(getTrendingUseCaseProvider),
        ref.watch(searchReposUseCaseProvider),
      );
    });
