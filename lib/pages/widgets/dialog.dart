import 'package:flutter/material.dart';

dialog(BuildContext context, String e) {
  return showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: const Text("Error"),
      content: Text(e),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Ok"),
        )
      ],
    ),
  );
}
