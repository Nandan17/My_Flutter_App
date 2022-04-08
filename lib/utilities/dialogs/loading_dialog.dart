import 'package:flutter/material.dart';

//we have a function that returns a closeDialog we call it showLoadingDialog
typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(text),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,//if user taps outside the dialog don't allow the dismissal of the dialog 
    builder: (context) => dialog,
  );

  return () => Navigator.of(context).pop();
}