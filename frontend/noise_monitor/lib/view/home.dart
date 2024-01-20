import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:noise_monitor/dialogs/room_creation.dart';
import 'package:noise_monitor/dialogs/room_subscription.dart';
import 'package:noise_monitor/tabs/device_configuration.dart';
import 'package:noise_monitor/tabs/home.dart';
import 'package:noise_monitor/utils/scaffold.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentPageIndex = 0;
  final List<Widget> _tabs = [const HomeTab(), const DeviceConfigurationTab()];

  Widget? _getFAB() {
    if (_currentPageIndex != 0) {
      return null;
    }

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.35,
      elevation: 8.0,
      children: [
        SpeedDialChild(
          shape: CircleBorder(),
          child: Icon(Icons.add),
          label: 'Create a new room',
          onTap: () => showDialog(
            context: context,
            builder: (context) => RoomCreationDialog(),
          ),
        ),
        SpeedDialChild(
          shape: CircleBorder(),
          child: Icon(Icons.link),
          label: 'Subscribe to room',
          onTap: () => showDialog(
            context: context,
            builder: (context) => RoomSubscriptionDialog(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoggedScaffold(
      floatingActionButton: _getFAB(),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Setup Device',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentPageIndex,
        children: _tabs,
      ),
    );
  }
}
