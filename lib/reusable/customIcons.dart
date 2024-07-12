import 'package:flutter/material.dart';

import '../consts/colors.dart';


class CustomIcon extends StatelessWidget {
  final IconData iconData;
  final Color color ;
  final double size ;
  const CustomIcon({required this.iconData,this.color = secondaryColor2,this.size = 30.0});

  @override
  Widget build(BuildContext context) {
    return  Icon(iconData, size: size,color: color,);
  }
}
