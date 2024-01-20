import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:noise_monitor/api/api.dart';

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

FutureOr<void> executeOrShowError(
  BuildContext context,
  FutureOr Function() fn,
) async {
  try {
    await fn();
  } catch (error) {
    late String message;
    if (error is ApiError) {
      message = error.toString();
    } else {
      print(error.toString());
      message = "Unknown error.";
    }
    showSnackbar(context, message);
  }
}

List<List<T>> chunk<T>(List<T> list, int chunkSize) {
  final result = <List<T>>[];
  for (int start = 0; start < list.length; start += chunkSize) {
    int end = min(start + chunkSize, list.length);
    result.add(list.sublist(start, end));
  }
  return result;
}
