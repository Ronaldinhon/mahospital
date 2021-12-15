import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      // child: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   // crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Text(
      //       '${patData['initial']}, ${patData['age']}yo ${patData['race']} $gender',
      //       style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      //     ),
      //     SizedBox(
      //       height: 15,
      //     ),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Text('Patient Id QR:'),
      //         SizedBox(
      //           width: 15,
      //         ),
      //         IconButton(
      //           icon: Icon(Icons.camera_alt),
      //           onPressed: () => _takePicture(),
      //         ),
      //         SizedBox(
      //           width: 10,
      //         ),
      //         IconButton(
      //           icon: Icon(Icons.photo),
      //           onPressed: () => _pickImage(),
      //         ),
      //       ],
      //     ),
      //     SizedBox(
      //       height: 20,
      //     ),
      //     Text(name ?? ''),
      //     Text(ptId ?? ''),
      //     Text(dob ?? ''),
      //     Text(address ?? ''),
      //   ],
      // ),
    );
  }
}
