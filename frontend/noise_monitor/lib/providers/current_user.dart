import 'dart:convert';

import 'package:noise_monitor/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:noise_monitor/api/api.dart' as api;

part 'current_user.g.dart';

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  Future<User?> build() async {
    return null;
  }

  Future<void> login(String email, String password, bool signup) async {
    if (signup) {
      await api.post(
        "/auth/signup/",
        body: jsonEncode({"email": email, "password": password}),
      );
    }
    
    final user = await api.login(email, password);
    state = AsyncData(user);
  }

  void logout() {
    api.logout();
    state = AsyncData(null);
  }
}
