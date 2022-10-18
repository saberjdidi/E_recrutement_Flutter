
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:e_recrutement/Jobs/jobs_screen.dart';
import 'package:e_recrutement/Jobs/upload_job.dart';
import 'package:e_recrutement/Search/profile_company.dart';
import 'package:e_recrutement/widgets/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Search/search_companies.dart';

class BottomNavigationBarForApp extends StatelessWidget {
  int indexNum = 0;
  BottomNavigationBarForApp({required this.indexNum});

  void _logout(context){
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.logout, size: 36, color: Colors.white,),
                ),
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 28),),
                )
              ],
            ),
            content: Text(
              'Do you want to logout ?',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: Text('No', style: TextStyle(color: Colors.green, fontSize: 18),)
              ),
              TextButton(
                  onPressed: (){
                    _auth.signOut();
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>UserState()));
                  },
                  child: Text('Yes', style: TextStyle(color: Colors.green, fontSize: 18),)
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    return CurvedNavigationBar(
      color: Colors.deepOrange.shade400,
      backgroundColor: Colors.blueAccent,
      buttonBackgroundColor: Colors.deepOrange.shade300,
      height: 50,
      index: indexNum,
        items: [
          Icon(Icons.list, size: 20, color: Colors.black,),
          Icon(Icons.search, size: 20, color: Colors.black,),
          Icon(Icons.add, size: 20, color: Colors.black,),
          Icon(Icons.account_circle, size: 20, color: Colors.black,),
          Icon(Icons.logout, size: 20, color: Colors.black,)
        ],
      animationDuration: Duration(milliseconds: 300),
      animationCurve: Curves.bounceInOut,
      onTap: (index) {
        if(index == 0){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>JobScreen()));
        }
        else if(index == 1){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>AllWorksScreen()));
        }
        else if(index == 2){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>UploadJobNow()));
        }
        else if(index == 3){
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>ProfileCompanyScreen(userId: uid)));
        }
        else if(index == 4){
          _logout(context);
        }
      },
    );
  }
}
