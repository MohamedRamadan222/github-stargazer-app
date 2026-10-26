import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_ce/hive.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/features/github/data/datasources/saved_local_data_source.dart';
import 'package:stargazer_app/features/github/data/models/saved_repo_model.dart';
import 'package:stargazer_app/features/github/data/repositories/saved_repository_impl.dart';
import 'package:stargazer_app/features/github/domain/usecases/get_saved_repos_usecase.dart';
import 'package:stargazer_app/features/github/domain/usecases/remove_repo_usecase.dart';
import 'package:stargazer_app/features/github/domain/usecases/save_repo_usecase.dart';

// Provider in the main
final savedBoxProvider = Provider<Box<SavedRepoModel>>(
  (ref) => throw UnimplementedError(),
);

// Data Source & Repository
final savedLocalDataSourceProvider = Provider(
  (ref) => SavedLocalDataSourceImpl(ref.watch(savedBoxProvider)),
);
final savedRepositoryProvider = Provider(
  (ref) => SavedRepositoryImpl(ref.watch(savedLocalDataSourceProvider)),
);

// Use Cases
final getSavedUseCaseProvider = Provider(
  (ref) => GetSavedReposUseCase(ref.watch(savedRepositoryProvider)),
);
final saveUseCaseProvider = Provider(
  (ref) => SaveRepoUseCase(ref.watch(savedRepositoryProvider)),
);
final removeUseCaseProvider = Provider(
  (ref) => RemoveRepoUseCase(ref.watch(savedRepositoryProvider)),
);

// state notifier
class SavedReposNotifier extends StateNotifier<AsyncValue<List<GithubRepo>>> {
  final GetSavedReposUseCase _getSaved;
  final SaveRepoUseCase _saveRepo;
  final RemoveRepoUseCase _removeRepo;

  SavedReposNotifier(this._getSaved, this._saveRepo, this._removeRepo)
    : super(const AsyncValue.loading()) {
    loadSavedRepos();
  }

  void loadSavedRepos() {
    final result = _getSaved();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (repos) {
        // الـ [...] بتجبر ريفر بود إنه يشوفها قائمة جديدة فيعمل Rebuild للشاشة
        state = AsyncValue.data([...repos]);
      },
    );
  }

  Future<void> toggleSave(GithubRepo repo) async {
    print('🔄 جاري محاولة حفظ/حذف المستودع...');
    final isSaved = state.value?.any((r) => r.id == repo.id) ?? false;

    if (isSaved) {
      await _removeRepo(repo.id);
      print('🗑️ تم الحذف بنجاح');
    } else {
      final result = await _saveRepo(repo);
      result.fold(
        (failure) => print('❌ فشل الحفظ: ${failure.message}'),
        (_) => print('✅ تم الحفظ بنجاح!'),
      );
    }
    loadSavedRepos(); // تحديث القائمة بعد الإضافة أو الحذف
  }
}

final savedReposProvider =
    StateNotifierProvider<SavedReposNotifier, AsyncValue<List<GithubRepo>>>((
      ref,
    ) {
      return SavedReposNotifier(
        ref.watch(getSavedUseCaseProvider),
        ref.watch(saveUseCaseProvider),
        ref.watch(removeUseCaseProvider),
      );
    });
