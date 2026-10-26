import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/github_repo.dart';
import '../../utils/number_formatter.dart';

class RepoCard extends StatelessWidget {
  final GithubRepo repo;

  const RepoCard({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/details', extra: repo);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(repo.owner.avatarUrl),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      repo.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (repo.description.isNotEmpty) ...[
                Text(
                  repo.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    repo.stargazersCount.toKFormat(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  if (repo.language.isNotEmpty) ...[
                    const Icon(
                      Icons.circle,
                      color: Colors.blueAccent,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(repo.language),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
