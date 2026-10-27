import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/custom_loading_indicator.dart';
import '../../../../core/presentation/widgets/repo_card.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider(username));

    // 1. حالة التحميل
    if (profileState.isLoading) {
      return const Scaffold(body: CustomLoadingIndicator());
    }

    // 2. حالة الخطأ
    if (profileState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileState.error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider(username).notifier).loadProfile(username),
                child: const Text('إعادة المحاولة'),
              )
            ],
          ),
        ),
      );
    }

    // 3. حالة عدم وجود بيانات (التأمين)
    if (profileState.user == null) {
      return const Scaffold(body: Center(child: Text('لم يتم العثور على بيانات المستخدم.')));
    }

    // 4. عرض البيانات بنجاح
    final user = profileState.user!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(user.login),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Top Repos'),
              Tab(text: 'Starred'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.avatarUrl)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name ?? user.login, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (user.bio != null) Text(user.bio!, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 16),
                            const SizedBox(width: 4),
                            Text('${user.followers} Followers • ${user.following} Following'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRepoList(profileState.repos),
                  _buildRepoList(profileState.starred),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoList(List repos) {
    if (repos.isEmpty) return const Center(child: Text('لا توجد مستودعات.'));
    return ListView.builder(
      itemCount: repos.length,
      itemBuilder: (context, index) => RepoCard(repo: repos[index]),
    );
  }
}