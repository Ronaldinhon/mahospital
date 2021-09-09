import 'package:flutter/material.dart';
import '../helpers/local_navigator.dart';
import '../widgets/side_menu.dart';

class MediumScreen extends StatelessWidget {
  const MediumScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: SideMenu()),
              Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: localNavigator(),
                  ))
            ],
          );
  }
}