import 'package:flutter/material.dart';
import '../helpers/reponsiveness.dart';
import '../widgets/horizontal_menu_item.dart';
import '../widgets/vertical_menu_item.dart';


class SideMenuItem extends StatelessWidget {
  final String itemName;
  final void Function() onTap;

  const SideMenuItem({ Key? key,required this.itemName,required this.onTap }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(ResponsiveWidget.isCustomSize(context)){
      return VertticalMenuItem(itemName: itemName, onTap: onTap,);
    }else{
      return HorizontalMenuItem(itemName: itemName, onTap: onTap,);
    }
  }
}