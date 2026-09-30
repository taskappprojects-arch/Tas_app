import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  final Box<String> _userBox = Hive.box<String>('userBox');

  UserProfile? get userProfile => _userProfile;
  bool get hasProfile => _userProfile != null;

  UserProvider() {
    _loadProfile();
  }

  void _loadProfile() {
    final profileStr = _userBox.get('profile');
    if (profileStr != null) {
      _userProfile = UserProfile.fromJson(profileStr);
      notifyListeners();
    }
  }

  void saveProfile(UserProfile profile) {
    _userProfile = profile;
    _userBox.put('profile', profile.toJson());
    notifyListeners();
  }
  void logout() {
    // For local pin lock, logout just means going back to PIN screen.
    // We don't delete the profile.
  }
}
