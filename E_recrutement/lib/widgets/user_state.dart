
import 'package:e_recrutement/Jobs/jobs_screen.dart';
import 'package:e_recrutement/LoginPage/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot){
          if(userSnapshot.data == null){
            print('user not logged in');
            return Login();
          }
          else if(userSnapshot.hasData){
            print('user is already logged in');
            return JobScreen();
          }
          else if(userSnapshot.hasError){
            return Scaffold(
              body: Center(
                child: Text(
                    'An error has been occured'
                ),
              ),
            );
          }
          else if(userSnapshot.connectionState == ConnectionState.waiting){
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: Text('Something went wrong'),
            ),
          );
        }
    );
  }
}
