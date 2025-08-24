// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:inventory/login.dart';
import 'package:inventory/register.dart';

class register_login extends StatefulWidget {
  const register_login({super.key});

  @override
  State<register_login> createState() => _register_loginState();
}

class _register_loginState extends State<register_login> {
  bool show = true;

  void toggle(){
    setState(() {
      show = !show;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (show)
      {

        return loginpage(ontap: toggle,);
      }
      else
        {
          return registerpage(ontap: toggle);
        }
  }
}
