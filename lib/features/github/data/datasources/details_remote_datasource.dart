import 'dart:convert';

import '../../../../core/network/dio_client.dart';
import '../models/github_repo_details_model.dart';

abstract class DetailsRemoteDatasource {
  Future<GithubRepoDetailsModel> getRepoDetails(String owner, String repoName);

  Future<String> getRepoReadme(String owner, String repoName);

  Future<Map<String, int>> getRepoLanguages(String owner, String repoName);
}

class DetailsRemoteDatasourceImpl implements DetailsRemoteDatasource {
  final DioClient dioClient;

  DetailsRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<GithubRepoDetailsModel> getRepoDetails(
    String owner,
    String repoName,
  ) async {
    final response = await dioClient.dio.get('/repos/$owner/$repoName');
    return GithubRepoDetailsModel.fromJson(response.data);
  }

  @override
  Future<String> getRepoReadme(String owner, String repoName) async {
    try {
      final response = await dioClient.dio.get(
        '/repos/$owner/$repoName/readme',
      );

      final contentBase64 = response.data['content'] as String;

      final cleanedBase64 = contentBase64.replaceAll('\n', '');

      final decodedReadme = utf8.decode(base64Decode(cleanedBase64));

      return decodedReadme;
    } catch (e) {
      return 'لا يوجد ملف README متاح أو حدث خطأ أثناء جلب الملف.';
    }
  }

  @override
  Future<Map<String, int>> getRepoLanguages(
    String owner,
    String repoName,
  ) async {
    final response = await dioClient.dio.get(
      '/repos/$owner/$repoName/languages',
    );
    return Map<String, int>.from(response.data);
  }
}
