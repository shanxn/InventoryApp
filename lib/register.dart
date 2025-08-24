// ignore_for_file: camel_case_types, unused_import, unused_local_variable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:inventory/myObj/Objects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory/buyer.dart';
import 'package:inventory/sell.dart';

class registerpage extends StatefulWidget {
  final void Function()? ontap;
  const registerpage({super.key, required this.ontap});

  @override
  State<registerpage> createState() => _registerpageState();
}

class _registerpageState extends State<registerpage> {
  final TextEditingController password_Controller = TextEditingController();

  final TextEditingController confpassword_Controller = TextEditingController();

  final TextEditingController user_Controller = TextEditingController();

  String errtxt = '';

  void registerUser() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    if (password_Controller.text == confpassword_Controller.text &&
        user_Controller.text.isNotEmpty) {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: user_Controller.text,
                password: password_Controller.text);
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        setState(() {
          errtxt = e.code;
        });
      }
    } else {
      setState(() {
        if (password_Controller.text != confpassword_Controller.text) {
          Navigator.pop(context);
          errtxt = "Passwords don't match";
        } else if (user_Controller.text.isEmpty) {
          Navigator.pop(context);
          errtxt = "Email can't be empty!";
        } else {
          errtxt = '';
        }
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
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.inversePrimary,
                blurRadius: 10,
              )
            ],
          ),
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
                    keyboardType: TextInputType.emailAddress,
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
                const SizedBox(
                  height: 10,
                  width: 10,
                ),
                TextField(
                  controller: confpassword_Controller,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 20,
                      )),
                ),
                Text(
                  errtxt,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
                Mybutton(
                  text: "R E G I S T E R",
                  onTap: () {
                    registerUser();

                  },
                  hgt: 50,
                  wth: 250,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Already have an account?",
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.inversePrimary)),
                    TextButton(
                        onPressed: widget.ontap,
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 12),
                        ))
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
