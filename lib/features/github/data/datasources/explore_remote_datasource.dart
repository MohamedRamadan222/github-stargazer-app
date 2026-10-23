import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/github_repo_model.dart';
import '../models/github_user_model.dart';

abstract class ExploreRemoteDatasource {
  Future<List<GithubRepoModel>> searchRepos(String query, {CancelToken? cancelToken});
  Future<List<GithubUserModel>> searchUsers(String query, {CancelToken? cancelToken});
  Future<List<GithubRepoModel>> getTrendingRepos({CancelToken? cancelToken});
}

class ExploreRemoteDatasourceImpl implements ExploreRemoteDatasource {
  final DioClient dioClient;

  ExploreRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<List<GithubRepoModel>> searchRepos(String query, {CancelToken? cancelToken}) async {
    final response = await dioClient.dio.get(
      '/search/repositories',
      queryParameters: {'q': query, 'per_page': 20},
      cancelToken: cancelToken,
    );
    return (response.data['items'] as List).map((e) => GithubRepoModel.fromJson(e)).toList();
  }

  @override
  Future<List<GithubUserModel>> searchUsers(String query, {CancelToken? cancelToken}) async {
    final response = await dioClient.dio.get(
      '/search/users',
      queryParameters: {'q': query, 'per_page': 20},
      cancelToken: cancelToken,
    );
    return (response.data['items'] as List).map((e) => GithubUserModel.fromJson(e)).toList();
  }

  @override
  Future<List<GithubRepoModel>> getTrendingRepos({CancelToken? cancelToken}) async {
    final date = DateTime.now().subtract(const Duration(days: 30));
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final response = await dioClient.dio.get(
      '/search/repositories',
      queryParameters: {
        'q': 'created:>$formattedDate',
        'sort': 'stars',
        'order': 'desc',
        'per_page': 20
      },
      cancelToken: cancelToken,
    );
    return (response.data['items'] as List).map((e) => GithubRepoModel.fromJson(e)).toList();
  }
}