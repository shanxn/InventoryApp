import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory/auth/reg_log.dart';
import 'package:inventory/buyer.dart';
import 'package:inventory/firebase.dart';

class authpage extends StatelessWidget {
  const authpage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot){
        if(snapshot.hasData){
          Data().FcmToken();
          return const buyer_();
        }
        else
          {
            return const register_login();
          }
      }),
    );
  }
}
