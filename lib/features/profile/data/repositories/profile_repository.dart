import 'package:flutter_app/features/profile/data/models/profile_model.dart';
import 'package:flutter_app/features/profile/data/repositories/profile_api.dart';

class ProfileRepository {
  final ProfileApi _api;
  ProfileRepository(this._api);

  Future<ProfileModel> getProfile() => _api.getProfile();
}
