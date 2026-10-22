import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/repo_card.dart';
import '../providers/saved_repos_provider.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../../../../core/domain/entities/github_user.dart';
import 'dart:math';

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedReposState = ref.watch(savedReposProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المحفوظات')),
      body: savedReposState.when(
        data: (repos) {
          if (repos.isEmpty) {
            return const Center(child: Text('مفيش مستودعات محفوظة لسة'));
          }
          return ListView.builder(
            itemCount: repos.length,
            itemBuilder: (context, index) {
              final repo = repos[index];
              return Dismissible(
                key: Key('${repo.id}'),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) =>
                    ref.read(savedReposProvider.notifier).toggleSave(repo),
                child: RepoCard(repo: repo),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
      // زرار مؤقت عشان نجرب نضيف داتا وهمية
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final randomId = Random().nextInt(1000000); // رقم عشوائي مسموح بيه في Hive

          final dummyRepo = GithubRepo(
            id: randomId, // استخدمنا الرقم العشوائي هنا
            name: 'Dummy Repo $randomId',
            fullName: 'User/Dummy Repo $randomId',
            description: 'تجربة حفظ أوفلاين',
            stargazersCount: 1500,
            language: 'Dart',
            owner: const GithubUser(id: 1, login: 'User', avatarUrl: 'https://github.com/flutter.png'),
          );

          ref.read(savedReposProvider.notifier).toggleSave(dummyRepo);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('جاري إضافة مستودع وهمي...'), duration: Duration(seconds: 1)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
