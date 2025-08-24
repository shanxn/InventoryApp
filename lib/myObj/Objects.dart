
// ignore_for_file: file_names, unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final double hgt;
  final double wth;
  const Mybutton({super.key, required this.text, required this.onTap, required this.hgt, required this.wth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
    child: Container(
      height: hgt,
      width: wth,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.primary ),
      child: Center(child: Text(text, style: const TextStyle(fontSize: 17),),),),);
  }
}
