import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LoginPage/login_screen.dart';
import 'widgets/user_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text('Erecrutement initialized',
                    style: TextStyle(
                      color: Colors.cyan, fontSize: 30, fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              ),
            );
          }
          else if(snapshot.hasError){
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Text('An error has been occured',
                    style: TextStyle(
                        color: Colors.cyan, fontSize: 40, fontWeight: FontWeight.bold
                    ),),
                ),
              ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'E-Recrutement App Flutter',
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.black,
              primarySwatch: Colors.blue
            ),
            home: UserState(),
          );
        }
    );
  }
}

