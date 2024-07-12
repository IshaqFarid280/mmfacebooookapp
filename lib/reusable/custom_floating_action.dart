import 'package:flutter/material.dart';

import '../consts/colors.dart';


class CustomFloatingAction extends StatelessWidget {
  final VoidCallback onTap ;
  const CustomFloatingAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed:onTap ,
    backgroundColor: secondaryColor2,
    elevation: 10,
    splashColor: iconColor,
    highlightElevation:10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(child:Icon(Icons.add,color: whiteColor,size: 35,),),);
  }
}
