import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/domain/entities/github_repo_details.dart';
import '../../data/datasources/details_remote_datasource.dart';
import '../../data/repositories/details_repository_impl.dart';
import '../../domain/usecases/get_repo_details_usecase.dart';
import '../../domain/usecases/get_repo_languages_usecase.dart';
import '../../domain/usecases/get_repo_readme_usecase.dart';

final detailsDatasourceProvider = Provider(
  (ref) => DetailsRemoteDatasourceImpl(
    dioClient: ref.watch(Provider((ref) => DioClient())),
  ),
);
final detailsRepositoryProvider = Provider(
  (ref) => DetailsRepositoryImpl(ref.watch(detailsDatasourceProvider)),
);

class RepoDetailsState {
  final bool isLoading;
  final String? error;
  final GithubRepoDetails? details;
  final String? readme;
  final Map<String, double>? languages;

  RepoDetailsState({
    this.isLoading = false,
    this.error,
    this.details,
    this.readme,
    this.languages,
  });
}

class DetailsNotifier extends StateNotifier<RepoDetailsState> {
  final DetailsRepositoryImpl _repo;

  DetailsNotifier(this._repo) : super(RepoDetailsState());

  Future<void> loadAll(String owner, String repoName) async {
    state = RepoDetailsState(isLoading: true);

    final detailsRes = await GetRepoDetailsUseCase(_repo).call(owner, repoName);
    final readmeRes = await GetRepoReadmeUseCase(_repo).call(owner, repoName);
    final langsRes = await GetRepoLanguagesUseCase(_repo).call(owner, repoName);

    if (detailsRes.isLeft()) {
      state = RepoDetailsState(
        error: detailsRes.getLeft().toNullable()?.message,
      );
      return;
    }

    state = RepoDetailsState(
      isLoading: false,
      details: detailsRes.getRight().toNullable(),
      readme: readmeRes.getRight().toNullable() ?? 'لا يوجد README',
      languages: langsRes.getRight().toNullable() ?? {},
    );
  }
}

final repoDetailsProvider =
    StateNotifierProvider<DetailsNotifier, RepoDetailsState>((ref) {
      return DetailsNotifier(ref.watch(detailsRepositoryProvider));
    });
