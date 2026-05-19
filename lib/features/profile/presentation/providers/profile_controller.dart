import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/features/profile/data/models/profile_model.dart';
import 'package:wave/features/profile/presentation/providers/profile_provider.dart';

class ProfileController extends AsyncNotifier<ProfileModel?> {
  @override
  Future<ProfileModel?> build() async => null;

  Future<void> loadProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).getProfile(),
    );
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileModel?>(
        ProfileController.new);
