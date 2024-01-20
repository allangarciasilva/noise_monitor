import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_monitor/providers/subscribed_rooms.dart';
import 'package:noise_monitor/utils/func.dart';

class RoomCreationDialog extends ConsumerStatefulWidget {
  const RoomCreationDialog({super.key});

  @override
  ConsumerState<RoomCreationDialog> createState() => _RoomCreationDialogState();
}

class _RoomCreationDialogState extends ConsumerState<RoomCreationDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a New Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                "Please fill below the data required for the new room.",
              ),
            ),
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.length == 0) {
                  return "Please insert a valid name.";
                }
                return null;
              },
              decoration: InputDecoration(
                label: const Text("Room Name"),
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
                  .createNewRoom(_nameController.text),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
