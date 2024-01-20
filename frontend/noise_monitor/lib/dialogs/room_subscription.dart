import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_monitor/providers/subscribed_rooms.dart';
import 'package:noise_monitor/utils/func.dart';

class RoomSubscriptionDialog extends ConsumerStatefulWidget {
  const RoomSubscriptionDialog({super.key});

  @override
  ConsumerState<RoomSubscriptionDialog> createState() =>
      _RoomSubscriptionDialogState();
}

class _RoomSubscriptionDialogState
    extends ConsumerState<RoomSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;

  @override
  void initState() {
    _idController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Subscribe to a Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                "Please fill below the data required for the new subscription.",
              ),
            ),
            TextFormField(
              controller: _idController,
              validator: (value) {
                if (value == null || int.tryParse(value) == null) {
                  return "Please insert a valid integer.";
                }
                return null;
              },
              decoration: InputDecoration(
                label: const Text("Room ID"),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Save'),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            await executeOrShowError(
              context,
              () => ref
                  .read(subscribedRoomsProvider.notifier)
                  .subscribe(int.parse(_idController.text)),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
