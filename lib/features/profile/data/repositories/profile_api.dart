import 'package:dio/dio.dart';
import 'package:wave/core/network/api_enpoints.dart';
import 'package:wave/features/profile/data/models/profile_model.dart';

class ProfileApi {
  final Dio _dio;
  ProfileApi(this._dio);

  Future<ProfileModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
