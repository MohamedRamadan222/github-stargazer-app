import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/get_user_repos_usecase.dart';
import '../../domain/usecases/get_user_starred_repos_usecase.dart';

final profileDatasourceProvider = Provider(
  (ref) => ProfileRemoteDatasourceImpl(
    dioClient: ref.watch(Provider((ref) => DioClient())),
  ),
);
final profileRepositoryProvider = Provider(
  (ref) => ProfileRepositoryImpl(ref.watch(profileDatasourceProvider)),
);

class ProfileState {
  final bool isLoading;
  final String? error;
  final UserProfile? user;
  final List<GithubRepo> repos;
  final List<GithubRepo> starred;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.user,
    this.repos = const [],
    this.starred = const [],
  });
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepositoryImpl _repo;

  ProfileNotifier(this._repo) : super(ProfileState());

  Future<void> loadProfile(String username) async {
    state = ProfileState(isLoading: true);

    final userRes = await GetUserProfileUseCase(_repo).call(username);
    final reposRes = await GetUserReposUseCase(_repo).call(username);
    final starredRes = await GetUserStarredReposUseCase(_repo).call(username);

    if (userRes.isLeft()) {
      state = ProfileState(error: userRes.getLeft().toNullable()?.message);
      return;
    }

    state = ProfileState(
      isLoading: false,
      user: userRes.getRight().toNullable(),
      repos: reposRes.getRight().toNullable() ?? [],
      starred: starredRes.getRight().toNullable() ?? [],
    );
  }
}

final profileProvider =
    StateNotifierProvider.family<ProfileNotifier, ProfileState, String>((
      ref,
      username,
    ) {
      return ProfileNotifier(ref.watch(profileRepositoryProvider))
        ..loadProfile(username);
    });
