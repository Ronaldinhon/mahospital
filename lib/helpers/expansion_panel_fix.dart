// import 'package:flutter/material.dart';

// class ExpansionPanelFix extends ExpansionPanel {
//   ExpansionPanelFix(
//       {required Object value,
//       required ExpansionPanelHeaderBuilder headerBuilder,
//       required Widget body})
//       : super(headerBuilder: headerBuilder, body: body);

//   void _handlePressed(bool isExpanded, int index) {
//     if (widget._allowOnlyOnePanelOpen) {
//       final ExpansionPanelRadio pressedChild =
//           widget.children[index] as ExpansionPanelRadio;

//       // If another ExpansionPanelRadio was already open, apply its
//       // expansionCallback (if any) to false, because it's closing.
//       for (int childIndex = 0;
//           childIndex < widget.children.length;
//           childIndex += 1) {
//         final ExpansionPanelRadio child =
//             widget.children[childIndex] as ExpansionPanelRadio;
//         if (widget.expansionCallback != null &&
//             childIndex != index &&
//             child.value == _currentOpenPanel?.value)
//           widget.expansionCallback!(childIndex, false);
//       }

//       widget.expansionCallback
//           ?.call(index, !isExpanded); // ***** LINE CHANGED AND MOVED

//       setState(() {
//         _currentOpenPanel = isExpanded ? null : pressedChild;
//       });
//     }
//   }
// }
