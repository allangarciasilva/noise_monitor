import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_monitor/providers/notification.dart';
import 'package:noise_monitor/view/device_monitoring.dart';
import 'package:noise_monitor/models/device.dart';
import 'package:noise_monitor/models/room.dart';
import 'package:noise_monitor/providers/subscribed_rooms.dart';
import 'package:noise_monitor/utils/card.dart';
import 'package:noise_monitor/utils/icon.dart';
import 'package:noise_monitor/utils/scaffold.dart';
import 'package:noise_monitor/api/api.dart' as api;

class RoomView extends ConsumerStatefulWidget {
  const RoomView({super.key, required this.room});

  final Room room;

  @override
  ConsumerState<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends ConsumerState<RoomView> {
  Future<List<Device>>? _roomDevices;

  void _refreshDevices() {
    _roomDevices = api.getRoomDevices(widget.room.id);
    ref.read(subscribedRoomsProvider.notifier).refresh();
  }

  @override
  void initState() {
    super.initState();
    _refreshDevices();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notificationProvider, (_, _1) => setState(_refreshDevices));

    return LoggedScaffold(
      body: RefreshIndicator(
        onRefresh: () async => setState(_refreshDevices),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: FutureBuilder(
              future: _roomDevices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text("Ops... Something happened.");
                }
                if (snapshot.hasData) {
                  return DeviceList(devices: snapshot.data!, room: widget.room);
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceList extends StatelessWidget {
  const DeviceList({super.key, required this.devices, required this.room});

  final Room room;
  final List<Device> devices;

  String _getEmptyScreenMessage() {
    if (room.editable) {
      return "Ugh! This room has no asigned devices.\nYou can configure one in the previous screen.";
    }
    return "Ugh! This room has no asigned devices.\nYou can wait for the room's creator to configure one.";
  }

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return Text(
        _getEmptyScreenMessage(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      );
    }
    return ListView(
      children: devices.map((device) => DeviceCard(device: device)).toList(),
    );
  }
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceMonitoringView(device: device),
          ),
        );
      },
      child: ListTile(
        leading: SensorIcon(active: device.active),
        title: Text(device.name),
      ),
    );
  }
}
