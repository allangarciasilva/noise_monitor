import 'dart:async';

import 'package:flutter/material.dart';

class TappableCard extends StatelessWidget {
  const TappableCard({super.key, required this.child, required this.onTap});

  final Widget child;
  final FutureOr Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).primaryColor.withAlpha(30),
        onTap: () async {
          await onTap();
        },
        child: child,
      ),
    );
  }
}
