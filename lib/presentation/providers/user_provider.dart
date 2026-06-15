import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

/// User Provider - State management untuk user
final currentUserProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  void setUser(UserModel user) {
    state = user;
  }

  void updateUser(UserModel user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  bool get isLoggedIn => state != null;
}

/// Authentication State Provider
final authStateProvider = StreamProvider<bool?>((ref) {
  // TODO: Implement auth state stream from Firebase
  return Stream.value(false);
});

/// User Profile Provider
final userProfileProvider = FutureProvider<UserModel?>((ref) {
  // TODO: Fetch user profile from Firestore
  return Future.value(null);
});

/// User Fields Provider
final userFieldsProvider = FutureProvider<List<dynamic>>((ref) {
  // TODO: Fetch user's fields from Firestore
  return Future.value([]);
});
