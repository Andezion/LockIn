import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/user_profile.dart';
import 'package:lockin/services/hive_service.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(HiveService.getProfile());

  void reload() {
    state = HiveService.getProfile();
  }

  Future<void> addXp(int xp) async {
    state.addXp(xp);
    await HiveService.saveProfile(state);
    reload();
  }

  Future<void> removeXp(int xp) async {
    state.removeXp(xp);
    await HiveService.saveProfile(state);
    reload();
  }

  Future<void> updateCategoryLevel(LifeCategory category, double points) async {
    state.updateCategoryLevel(category, points);
    await HiveService.saveProfile(state);
    reload();
  }

  Future<void> updateStreak(DateTime activityDate) async {
    state.updateStreak(activityDate);
    await HiveService.saveProfile(state);
    reload();
  }

  Future<void> checkStreakBreak() async {
    state.checkStreakBreak();
    await HiveService.saveProfile(state);
    reload();
  }
}
