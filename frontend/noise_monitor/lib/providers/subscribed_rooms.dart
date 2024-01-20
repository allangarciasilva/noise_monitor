import 'dart:convert';

import 'package:noise_monitor/models/room.dart';
import 'package:noise_monitor/providers/current_user.dart';
import 'package:noise_monitor/providers/notification.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:noise_monitor/api/api.dart' as api;

part 'subscribed_rooms.g.dart';

@riverpod
class SubscribedRooms extends _$SubscribedRooms {
  @override
  Future<List<Room>> build() async {
    ref.watch(notificationStreamProvider);
    final user = ref.watch(currentUserProvider);
    if (user.hasValue && user.value != null) {
      final body = await api.get('/rooms/');
      return (body as List<dynamic>).map((e) => Room.fromJson(e)).toList();
    }
    return [];
  }

  void refresh() async {
    ref.invalidateSelf();
  }

  Future createNewRoom(String name) async {
    await api.post("/rooms/", body: jsonEncode({"name": name}));
    refresh();
  }

  Future subscribe(int roomId) async {
    await api.post(
      "/rooms/$roomId/subscription/",
    );
    refresh();
  }

  Future unsubscribe(int roomId) async {
    await api.delete(
      "/rooms/$roomId/subscription/",
    );
    refresh();
  }
}
