// ignore_for_file: camel_case_types, non_constant_identifier_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory/myObj/Objects.dart';
import 'package:inventory/sell.dart';

class loginpage extends StatefulWidget {
  final void Function()? ontap;
  const loginpage({super.key, required this.ontap});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  String errtext ='';
  final TextEditingController password_Controller = TextEditingController();

  final TextEditingController user_Controller = TextEditingController();


  void loginuser() async{
    showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ));
    try{

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: user_Controller.text, password: password_Controller.text);

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      setState(() {
        errtext = e.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Center(
        child: Container(

          height: 500,
          width: 300,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Theme.of(context).colorScheme.inversePrimary,
                blurRadius: 10,


              )
            ],
              color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_rounded,
                  size: 50,
                ),
                const Center(
                  child: Text(
                    'O R D E R Y',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                const SizedBox(height: 30, width: 30),
                TextField(
                    controller: user_Controller,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(
                          Icons.person,
                          size: 20,
                        ))),
                const SizedBox(
                  height: 10,
                  width: 10,
                ),
                TextField(
                  controller: password_Controller,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 20,
                      )),
                ),
                Text(errtext),
                Mybutton(
                  text: "L O G I N",
                  onTap: () {
                        loginuser();
                      const seller_();
                  },
                  hgt: 50,
                  wth: 250,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Don't have an account?",style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.inversePrimary),),
                    TextButton(onPressed: widget.ontap, child: const Text('Register now', style: TextStyle(fontSize: 12),))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
