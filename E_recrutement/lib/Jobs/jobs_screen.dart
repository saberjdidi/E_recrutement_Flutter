
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/Search/search_job.dart';
import 'package:e_recrutement/widgets/job_widget.dart';
import 'package:e_recrutement/widgets/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Persistent/persistent.dart';
import '../widgets/bottom_nav_bar.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);

  @override
  _JobScreenState createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? jobCategoryFilter;

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context, builder: (builder) {
      return AlertDialog(
        backgroundColor: Colors.black54,
        title: Text(
          'Job Category',
          style: TextStyle(
              fontSize: 20, color: Colors.white
          ),
        ),
        content: Container(
          width: size.width * 0.9,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: Persistent.jobCategoryList.length,
              itemBuilder: (builder, index){
                return InkWell(
                  onTap: (){
                    setState(() {
                      jobCategoryFilter = Persistent.jobCategoryList[index];
                    });
                   Navigator.canPop(context) ? Navigator.pop(context) : null;
                   print('job category : ${Persistent.jobCategoryList[index]}');
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right_alt_outlined, color: Colors.grey,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(Persistent.jobCategoryList[index],
                            style: TextStyle(color: Colors.grey, fontSize: 16),),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white, fontSize: 17),
              )
          ),
          TextButton(
              onPressed: (){
                setState(() {
                  jobCategoryFilter = null;
                });
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 17),
              )
          )
        ],
      );
    }
    ) ;
  }

  @override
  void initState() {
    super.initState();
    Persistent persistentObject = Persistent();
    persistentObject.getCurrentUser();
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
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0,),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          //title: const Text('Jobs Screen'),
          //centerTitle: true,
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
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.filter_list_rounded, color: Colors.black,),
            onPressed: (){
              _showTaskCategoriesDialog(size: size);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_outlined, color: Colors.black,),
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>SearchJob()));
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('jobCategory', isEqualTo: jobCategoryFilter)
          .where('recruitment', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .snapshots(),
          builder: (context, AsyncSnapshot snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            else if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.data?.docs.isNotEmpty == true) {
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (BuildContext context, int index){
                      return JobWidget(
                          jobTitle: snapshot.data?.docs[index]['jobTitle'],
                          jobDescription: snapshot.data?.docs[index]['jobDescription'],
                          jobId: snapshot.data?.docs[index]['jobId'],
                          uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                          userImage: snapshot.data?.docs[index]['userImage'],
                          name: snapshot.data?.docs[index]['name'],
                          recruitment: snapshot.data?.docs[index]['recruitment'],
                          email: snapshot.data?.docs[index]['email'],
                          location: snapshot.data?.docs[index]['location']
                      );
                    }
                    );
              }
              else if(snapshot.data?.docs.isEmpty == true) {
                Center(
                  child: Text('Empty List',
                    style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
                );
              }
              else {
                Center(
                  child: Text('Empty List',
                  style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
                );
              }
            }

             return Center(
                child: Text('Something went wrong',
                  style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
              );

          },
        ),
      ),
    );
  }
}
