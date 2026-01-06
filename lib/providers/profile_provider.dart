import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/action_log.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/models/user_profile.dart';
import 'package:lockin/services/hive_service.dart';
import 'package:lockin/services/xp_calculator.dart';
import 'package:uuid/uuid.dart';

/// Provider for user profile
final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(HiveService.getProfile());

  /// Reload profile from database
  void reload() {
    state = HiveService.getProfile();
  }

  /// Add XP and update profile
  Future<void> addXp(int xp) async {
    state.addXp(xp);
    await HiveService.saveProfile(state);
    reload();
  }

  /// Remove XP (penalty) and update profile
  Future<void> removeXp(int xp) async {
    state.removeXp(xp);
    await HiveService.saveProfile(state);
    reload();
  }

  /// Update category level
  Future<void> updateCategoryLevel(LifeCategory category, double points) async {
    state.updateCategoryLevel(category, points);
    await HiveService.saveProfile(state);
    reload();
  }

  /// Update streak
  Future<void> updateStreak(DateTime activityDate) async {
    state.updateStreak(activityDate);
    await HiveService.saveProfile(state);
    reload();
  }

  /// Check and break streak if needed
  Future<void> checkStreakBreak() async {
    state.checkStreakBreak();
    await HiveService.saveProfile(state);
    reload();
  }
}
