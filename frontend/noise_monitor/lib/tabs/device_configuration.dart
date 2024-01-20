import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_monitor/models/room.dart';
import 'package:noise_monitor/proto/ESPConfig.pb.dart';
import 'package:noise_monitor/providers/subscribed_rooms.dart';
import 'package:noise_monitor/utils/card.dart';
import 'package:noise_monitor/utils/func.dart';

class DeviceConfigurationTab extends StatefulWidget {
  const DeviceConfigurationTab({super.key});

  @override
  State<DeviceConfigurationTab> createState() => _DeviceConfigurationTabState();
}

class _DeviceConfigurationTabState extends State<DeviceConfigurationTab> {
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    _startScanning();
    super.initState();
  }

  Future<void> _startScanning() async {
    setState(() => _devices.clear());

    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen(
      (results) {
        for (ScanResult result in results) {
          if (!_devices.contains(result.device) &&
              result.device.platformName.startsWith("ESP32")) {
            setState(() => _devices.add(result.device));
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator(
        onRefresh: _startScanning,
        child: Builder(builder: (context) {
          if (_devices.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: _devices
                .map(
                  (device) => TappableCard(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) =>
                          DeviceConfigurationDialog(device: device),
                    ),
                    child: ListTile(
                      title: Text(device.platformName),
                      subtitle: Text(device.remoteId.toString()),
                    ),
                  ),
                )
                .toList(),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }
    super.dispose();
  }
}

class DeviceConfigurationDialog extends StatefulWidget {
  const DeviceConfigurationDialog({
    super.key,
    required this.device,
  });

  final BluetoothDevice device;

  @override
  State<DeviceConfigurationDialog> createState() =>
      _DeviceConfigurationDialogState();
}

String getHex(List<int> data) {
  return data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
}

class _DeviceConfigurationDialogState extends State<DeviceConfigurationDialog> {
  final _formKey = GlobalKey<FormState>();
  BluetoothCharacteristic? _characteristic;

  bool _sending = false;

  late TextEditingController _ssidController;
  late TextEditingController _passwordController;
  int? _selectedRoomId;

  String? _dropdownError;

  @override
  void initState() {
    _ssidController = TextEditingController();
    _passwordController = TextEditingController();
    widget.device.connect().then((value) => _loadCharacteristics());
    super.initState();
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  Future<void> _writeSettings() async {
    final settings = ESPConfig(
      wifiSsid: _ssidController.text,
      wifiPassword: _passwordController.text,
      roomId: _selectedRoomId,
    );

    final data = settings.writeToBuffer();
    final chunks = chunk(data, 20);

    for (int i = 0; i < chunks.length - 1; i++) {
      await _characteristic!.write([1] + chunks[i]);
    }

    await _characteristic!.write([0] + chunks.last);
    print("Finished writing");
  }

  Future<void> _loadCharacteristics() async {
    if (!widget.device.isConnected) {
      return;
    }

    final services = await widget.device.discoverServices();
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() => _characteristic = characteristic);
        }
      }
    }
  }

  void _onSubmit() async {
    bool formValid = _formKey.currentState!.validate();

    late bool selectionValid;
    if (_selectedRoomId == null) {
      selectionValid = false;
      setState(
        () => _dropdownError = "A room must be selected.",
      );
    } else {
      selectionValid = true;
      setState(() => _dropdownError = null);
    }

    if (!(formValid && selectionValid)) {
      return;
    }

    try {
      setState(() => _sending = true);
      await _writeSettings();
    } catch (error) {
      showSnackbar(
        context,
        "An error ocurred. Restart the device and try again.",
      );
    }
    setState(() => _sending = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Device Configuration"),
      content: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _ssidController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "SSID cannot be empty.";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text("WiFi SSID"),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return "Minimum password length is 8.";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text("WiFi Password"),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                      child: RoomSelector(
                    errorText: _dropdownError,
                    onSelectionChanged: (value) {
                      _selectedRoomId = value;
                    },
                  )),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: (_characteristic == null || _sending)
                        ? null
                        : _onSubmit,
                    child: Text("Submit"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RoomSelector extends ConsumerStatefulWidget {
  const RoomSelector({super.key, this.errorText, this.onSelectionChanged});

  final String? errorText;
  final Function(int?)? onSelectionChanged;

  @override
  ConsumerState<RoomSelector> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends ConsumerState<RoomSelector> {
  @override
  Widget build(BuildContext context) {
    final options = ref.watch(subscribedRoomsProvider).when(
          data: (data) => data.where((room) => room.editable),
          error: (error, _) {
            debugPrint(error.toString());
            return <Room>[];
          },
          loading: () => <Room>[],
        );

    return DropdownMenu<int>(
      initialSelection: null,
      expandedInsets: EdgeInsets.zero,
      label: Text("Room"),
      errorText: widget.errorText,
      onSelected: widget.onSelectionChanged,
      dropdownMenuEntries: options.map((Room room) {
        return DropdownMenuEntry<int>(value: room.id, label: room.name);
      }).toList(),
    );
  }
}
