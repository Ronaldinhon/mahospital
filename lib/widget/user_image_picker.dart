import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imageFn);
  final void Function(File pickedImage) imageFn;
  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  late File _pickedImage;
  final picker = ImagePicker();

  void _pickImage() async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      // imageQuality: 50,
      // maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imageFn(pickedImageFile);
  }

  void _takePicture() async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      // imageQuality: 50,
      // maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imageFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 70,
          backgroundColor: Color(0xffdadada),
          backgroundImage: _pickedImage != null
              ? FileImage(
                  _pickedImage,
                )
              : null,
          child: _pickedImage == null
              ? Text(
                  'Image/Logo',
                  textAlign: TextAlign.center,
                )
              : null,
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _pickImage,
              icon: Icon(
                Icons.image,
              ),
            ),
            SizedBox(width: 28,),
            IconButton(
              onPressed: _takePicture,
              icon: Icon(
                Icons.camera_alt,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
