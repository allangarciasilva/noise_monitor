import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_monitor/providers/current_user.dart';
import 'package:noise_monitor/providers/notification.dart';

class LoggedScaffold extends ConsumerStatefulWidget {
  const LoggedScaffold({
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget body;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoggedScaffoldState();
}

class _LoggedScaffoldState extends ConsumerState<LoggedScaffold> {
  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Noise Monitor"),
        actions: [
          IconButton(
            icon: Icon(notifications.isEmpty
                ? Icons.notifications_outlined
                : Icons.notification_important),
            onPressed: notifications.isEmpty
                ? null
                : () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NotificationDialog();
                      },
                    ),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              ref.read(currentUserProvider.notifier).logout();
            },
          )
        ],
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      body: widget.body,
    );
  }
}

class NotificationDialog extends ConsumerWidget {
  const NotificationDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    // .when(
    //       data: (data) => data,
    //       error: (error, _) {
    //         debugPrint(error.toString());
    //         return <String>[];
    //       },
    //       loading: () => <String>[],
    //     );

    return AlertDialog(
      title: Text("Notifications"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(notificationProvider.notifier).reset();
          },
          child: Text("Clear"),
        ),
      ],
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (_, index) => Text(
            notifications[index],
          ),
          separatorBuilder: (_, index) => Divider(),
          itemCount: notifications.length,
        ),
      ),
    );
  }
}
