import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/custom_loading_indicator.dart';
import '../../../../core/presentation/widgets/repo_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../profile_widgets/profile_header.dart';
import '../profile_widgets/tabs.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, required this.username});

  final String username;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider(widget.username));

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: CustomLoadingIndicator(),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref
                      .read(profileProvider(widget.username).notifier)
                      .loadProfile(widget.username),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = state.user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('User not found.')),
      );
    }

    final repos = switch (_tab) {
      0 => state.repos.take(2).toList(),
      1 => state.repos,
      _ => state.starred,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.border),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    avatarUrl: user.avatarUrl,
                    name: user.name ?? user.login,
                    login: user.login,
                    bio: user.bio,
                    followers: user.followers,
                    following: user.following,
                  ),
                  const SizedBox(height: 20),
                  Tabs(
                    selected: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                    reposCount: state.repos.length,
                    starsCount: state.starred.length,
                  ),
                  const SizedBox(height: 20),
                  if (_tab == 0) ...[
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pinned repositories',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.push_pin_outlined,
                          size: 18,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: repos.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('No repositories.')),
                    ),
                  )
                : SliverList.separated(
                    itemCount: repos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => RepoCard(repo: repos[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
