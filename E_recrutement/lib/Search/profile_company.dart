import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/Services/global_methods.dart';
import 'package:e_recrutement/widgets/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Services/global_variables.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileCompanyScreen extends StatefulWidget {
  final String userId;
  const ProfileCompanyScreen({required this.userId});

  @override
  State<ProfileCompanyScreen> createState() => _ProfileCompanyScreenState();
}

class _ProfileCompanyScreenState extends State<ProfileCompanyScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String? email = '';
  String? phoneNumber = '';
  String imageurl = '';
  String? joinedAt = '';
  bool _isLoading = false;
  bool _isSameUser = false;

  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
       .collection('users').doc(widget.userId).get();
      if(userDoc == null){
        return;
      }
      else {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageurl = userDoc.get('userImage');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userId;
        });
      }
    }
    catch(exception){
      GlobalMethod.showErrorDialog(error: exception.toString(), context: context);
      _isLoading = false;
    }
    finally {
      _isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Widget userInfo({required IconData icon, required String? content}){
    return Row(
      children: [
        Icon(icon, color: Colors.white,),
        Padding(padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(content!, style: TextStyle(color: Colors.white54),),)
      ],
    );
  }

  Widget _contactBy({required Color color, required Function fct, required IconData icon}){
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 23,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: (){
            fct();
          },
        ),
      ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    launchUrlString(url);
  }
  _mailTo(){
    final Uri params = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Write subject...&body=Hello, please write details here'
    );
    final url = params.toString();
    launchUrlString(url);

  }
  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.deepOrange.shade300, Colors.blueAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.2, 0.9]
          )
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 3),
        backgroundColor: Colors.transparent,
       /* appBar: AppBar(
          title: const Text('Profile Company'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.2, 0.9]
                )
            ),
          ),
        ), */
        body: Center(
          child: _isLoading
          ? Center(child: CircularProgressIndicator(),)
          : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 30),
              child: Stack(
                children: [
                  Card(
                    color: Colors.white10,
                    margin: EdgeInsets.all(30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 100,),
                          Align(
                            alignment: Alignment.center,
                            child: Text(name==null ? 'name here' : name!,
                            style: TextStyle(color: Colors.white, fontSize: 24),),
                          ),
                          const SizedBox(height: 15,),
                          Divider(
                            thickness: 1,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 30,),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Account Information',
                              style: TextStyle(color: Colors.white54, fontSize: 22),),
                          ),
                          const SizedBox(height: 15,),
                          Padding(
                            padding: const EdgeInsets.only(left: 10 ),
                            child: userInfo(icon: Icons.email, content: email),
                          ),
                          const SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.only(left: 10 ),
                            child: userInfo(icon: Icons.phone, content: phoneNumber),
                          ),
                          const SizedBox(height: 15,),
                          Divider(
                            thickness: 1,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 35,),
                           _isSameUser
                          ? Container()
                           : Row(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                             children: [
                               _contactBy(
                                   color: Colors.green,
                                   fct: (){
                                     _openWhatsAppChat();
                                   },
                                   icon: FontAwesome.whatsapp
                               ),
                               _contactBy(
                                   color: Colors.red,
                                   fct: (){
                                     _mailTo();
                                   },
                                   icon: Icons.mail_outline
                               ),
                               _contactBy(
                                   color: Colors.purple,
                                   fct: (){
                                     _callPhoneNumber();
                                   },
                                   icon: Icons.call
                               ),
                             ],
                           ),
                          !_isSameUser
                          ? Container()
                          : Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 30),
                              child: MaterialButton(
                                onPressed: (){
                                  _auth.signOut();
                                  Navigator.pushReplacement(context, 
                                  MaterialPageRoute(builder: (context) => UserState()));
                                },
                                color: Colors.black,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Logout',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,
                                          fontFamily: 'Signatra', fontSize: 28),),
                                      SizedBox(width: 8.0,),
                                      Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.26,
                        height: size.width * 0.26,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 6,
                            color: Theme.of(context).scaffoldBackgroundColor
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              // ignore: prefer_if_null_operators
                              imageurl == null
                                  ? userProfileImage
                                  : imageurl
                            ),
                            fit: BoxFit.fill
                          )
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}
