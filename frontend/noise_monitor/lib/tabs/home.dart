import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_monitor/models/room.dart';
import 'package:noise_monitor/providers/subscribed_rooms.dart';
import 'package:noise_monitor/utils/card.dart';
import 'package:noise_monitor/utils/func.dart';
import 'package:noise_monitor/utils/icon.dart';
import 'package:noise_monitor/view/room.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(subscribedRoomsProvider);

    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(subscribedRoomsProvider.notifier).refresh(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: rooms.when(
            data: (rooms) => RoomList(rooms: rooms),
            error: (error, _s) {
              debugPrint(error.toString());
              return Text("Ops... Something happened.");
            },
            loading: () => CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class RoomList extends StatelessWidget {
  const RoomList({
    super.key,
    required this.rooms,
  });

  final List<Room> rooms;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return Text(
        "Ugh! You have no rooms!\nSubscribe to one or create your own.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      );
    }

    return ListView(
      children: rooms
          .map(
            (room) => Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: RoomCard(room: room),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class RoomCard extends ConsumerStatefulWidget {
  const RoomCard({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  ConsumerState<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends ConsumerState<RoomCard> {
  void _onUnsubscribe(BuildContext context) async {
    await executeOrShowError(
      context,
      () => ref
          .read(subscribedRoomsProvider.notifier)
          .unsubscribe(widget.room.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomView(room: widget.room),
          ),
        );
      },
      child: ListTile(
        leading: SensorIcon(active: widget.room.activeDevices > 0),
        title: Text(widget.room.name),
        subtitle: Text(
          'Id: ${widget.room.id} | Online devices: ${widget.room.activeDevices}',
        ),
        trailing: widget.room.editable
            ? null
            : IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => _onUnsubscribe(context),
              ),
      ),
    );
  }
}
