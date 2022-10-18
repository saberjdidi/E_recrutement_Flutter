import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/Services/global_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Jobs/job_details.dart';

class JobWidget extends StatefulWidget {
  final String jobTitle;
  final String jobDescription;
  final String jobId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final bool recruitment;
  final String email;
  final String location;

  const JobWidget({
    required this.jobTitle,
    required this.jobDescription,
    required this.jobId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
  });

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  _deleteDialog() async {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            content: Text('Do you want to delete this item ?', style: TextStyle(
              fontSize: 20, color: Colors.black
            ),),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: (){
                        Navigator.canPop(context) ? Navigator.pop(context) : null;
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel, color: Colors.blue,),
                          Text('Cancel', style: TextStyle(color: Colors.blue),)
                        ],
                      )),
                  TextButton(
                      onPressed: () async {
                        try {
                          if(widget.uploadedBy == _uid){
                            await FirebaseFirestore.instance.collection('jobs')
                                .doc(widget.jobId).delete();

                            await Fluttertoast.showToast(
                                msg: 'Job has been deleted!',
                                toastLength: Toast.LENGTH_LONG,
                                backgroundColor: Colors.grey,
                                fontSize: 18.0
                            );
                           await Navigator.canPop(context) ? Navigator.pop(context) : null;
                          }
                          else {
                            await Fluttertoast.showToast(
                                msg: 'You dont have access to delete this job',
                                toastLength: Toast.LENGTH_LONG,
                                backgroundColor: Colors.grey,
                                fontSize: 18.0
                            );
                           await Navigator.canPop(context) ? Navigator.pop(context) : null;
                          }
                        }
                        catch(Error){
                          GlobalMethod.showErrorDialog(error: 'Error : ${Error.toString()}', context: context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Colors.red,),
                          Text('Delete', style: TextStyle(color: Colors.red),)
                        ],
                      )
                  )
                ],
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      elevation: 8,
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobDetails(uploadedBy: widget.uploadedBy, jobId: widget.jobId,)));
        },
        onLongPress: (){
          _deleteDialog();
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 1)
            )
          ),
          child: Image.network(widget.userImage),
        ),
        title: Text(
          widget.jobTitle,
          maxLines: 2,
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13
              ),
            ),
            SizedBox(height: 8.0,),
            Text(
              widget.jobDescription,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }
}
