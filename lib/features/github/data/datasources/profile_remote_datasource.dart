import '../../../../core/network/dio_client.dart';
import '../models/github_repo_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfileModel> getUserProfile(String username);
  Future<List<GithubRepoModel>> getUserRepos(String username);
  Future<List<GithubRepoModel>> getUserStarredRepos(String username);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final DioClient dioClient;
  ProfileRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<UserProfileModel> getUserProfile(String username) async {
    final response = await dioClient.dio.get('/users/$username');
    return UserProfileModel.fromJson(response.data);
  }

  @override
  Future<List<GithubRepoModel>> getUserRepos(String username) async {
    final response = await dioClient.dio.get('/users/$username/repos');
    return (response.data as List)
        .map((e) => GithubRepoModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<GithubRepoModel>> getUserStarredRepos(String username) async {
    final response = await dioClient.dio.get('/users/$username/starred');
    return (response.data as List)
        .map((e) => GithubRepoModel.fromJson(e))
        .toList();
  }
}
