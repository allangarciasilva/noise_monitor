import 'dart:convert';

import 'package:noise_monitor/providers/current_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:noise_monitor/api/api.dart' as api;

part 'notification.g.dart';

class _Notification {
  _Notification(this.text, this.id);

  String text;
  int id;
}

@Riverpod(keepAlive: true)
Stream<_Notification> notificationStream(NotificationStreamRef ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user.hasValue && user.value != null) {
    final ws = api.connectToWebsocket("/ws/user/");
    ref.onDispose(ws.sink.close);

    int id = 0;
    await for (final value in ws.stream) {
      final decoded = jsonDecode(value);
      if (decoded is String) {
        yield _Notification(decoded, id);
        id++;
      }
    }
  }
}

List<String> _allNotifications = [];
int? lastId = null;

@riverpod
class Notification extends _$Notification {
  @override
  List<String> build() {
    final stream = ref.watch(notificationStreamProvider);
    if (stream.hasValue && stream.value!.id != lastId) {
      _allNotifications.add(stream.value!.text);
      lastId = stream.value!.id;
    }
    return [..._allNotifications];
  }

  void reset() {
    _allNotifications.clear();
    lastId = null;
    state = [];
  }
}
