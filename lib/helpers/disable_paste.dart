import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final pasteKeySetwindows = LogicalKeySet(
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.keyV,
);

/// i dont have any ios device 😅,let me know what it produce.
final pasteKeySetMac = LogicalKeySet(
  LogicalKeyboardKey.meta,
  LogicalKeyboardKey.keyV,
);

class PasteIntent extends Intent {}

class DisableShortcut extends StatelessWidget {
  final Widget child;

  const DisableShortcut({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        pasteKeySetwindows: PasteIntent(),
        pasteKeySetMac: PasteIntent(),
      },
      actions: {
        PasteIntent: CallbackAction(
          onInvoke: (intent) async {
            return ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Paste is forbidden")));
          },
        )
      },
      autofocus: true,
      child: child,
    );
  }
}
