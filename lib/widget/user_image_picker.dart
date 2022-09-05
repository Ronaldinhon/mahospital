import 'dart:io';
// import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/firebase.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imageFn);
  final void Function(XFile pickedImage) imageFn;
  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedIma = File('');
  late XFile? pickedImage;
  final picker = ImagePicker();

  void _pickImage() async {
    pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      // imageQuality: 50,
      // maxWidth: 150,
    );
    // html.File imageFile =
    //     await ImagePickerForWeb.getImage(outputType: ImageType.file);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedIma = pickedImageFile;
    });
    // widget.imageFn(pickedImageFile);
    widget.imageFn(pickedImage!);
  }

  void _takePicture() async {
    pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      // imageQuality: 50,
      // maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    // hjk = PickedFile(pickedImage.path);
    setState(() {
      _pickedIma = pickedImageFile;
    });
    // widget.imageFn(pickedImageFile);
    widget.imageFn(pickedImage!);
  }

  ImageProvider<Object> justReturnImage() {
    if (kIsWeb)
      return NetworkImage(_pickedIma.path);
    else
      return FileImage(
        _pickedIma,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 70,
          backgroundColor: Color(0xffdadada),
          backgroundImage:
              _pickedIma.path.isNotEmpty ? justReturnImage() : null,
          child: _pickedIma.path.isEmpty
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
            isWebMobile
                ? SizedBox(
                    width: 28,
                  )
                : Container(),
            isWebMobile // why only webMobile?
                ? IconButton(
                    onPressed: _takePicture,
                    icon: Icon(
                      Icons.camera_alt,
                    ),
                  )
                : Container(),
          ],
        ),
      ],
    );
  }
}
