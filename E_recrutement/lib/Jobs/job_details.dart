
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/Jobs/jobs_screen.dart';
import 'package:e_recrutement/Services/global_methods.dart';
import 'package:e_recrutement/widgets/comment_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../Services/global_variables.dart';

class JobDetails extends StatefulWidget {
  final String uploadedBy;
  final String jobId;
  const JobDetails({
    required this.uploadedBy,
    required this.jobId,
});

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _commentController = TextEditingController();

  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobTitle;
  String? jobDescription;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = '';
  String? emailCompany = '';
  int applicants = 0;
  bool isDeadlineAvailable = false;

  bool _isCommenting = false;
  bool showComment = false;

  void getJobData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if(userDoc == null){
      return;
    }
    else {
      authorName = userDoc.get('name');
      userImageUrl = userDoc.get('userImage');
    }
    final DocumentSnapshot jobDocument = await FirebaseFirestore.instance
           .collection('jobs')
           .doc(widget.jobId)
           .get();
    if(jobDocument == null){
      return;
    }
    else {
      setState(() {
        jobTitle = jobDocument.get('jobTitle');
        jobDescription = jobDocument.get('jobDescription');
        jobCategory = jobDocument.get('jobCategory');
        recruitment = jobDocument.get('recruitment');
        emailCompany = jobDocument.get('email');
        locationCompany = jobDocument.get('location');
        applicants = jobDocument.get('applicants');
        postedDateTimeStamp = jobDocument.get('createdAt');
        deadlineDateTimeStamp = jobDocument.get('deadlineDateTimeStamp');
        deadlineDate = jobDocument.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  @override
  void initState() {
    super.initState();
    getJobData();
  }

  Widget DividerWidget(){
    return Column(
      children: [
        SizedBox(height: 10.0,),
        Divider(thickness: 1, color: Colors.grey,),
        SizedBox(height: 10.0,),
      ],
    );
  }

  applyForJob(){
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query: 'subject=Applying for $jobTitle&body=Hello, please attach Resume/CV file'
    );
    final url = params.toString();
    launchUrlString(url);
    addNewApplicant();
  }
  void addNewApplicant() async {
    var docRef = await FirebaseFirestore.instance
         .collection('jobs')
        .doc(widget.jobId);
     docRef.update({
       'applicants' : applicants + 1
     });
     Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
        //bottomNavigationBar: BottomNavigationBarForApp(indexNum: 1),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          //title: const Text('Search Job'),
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
          leading: IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobScreen()));
            },
            icon: Icon(Icons.close, size: 40, color: Colors.white,),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.white10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(jobTitle==null ?'' :jobTitle!,
                          maxLines: 3,
                            style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30
                            ),
                          ),
                        ),
                        SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.grey
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                       ? userProfileImage
                                        : userImageUrl!
                                  ),
                                  fit: BoxFit.fill
                                )
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(authorName==null ?'' :authorName!,
                                    maxLines: 3,
                                    style: TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16
                                    ),
                                  ),
                                  Text(locationCompany==null ?'' :locationCompany!,
                                    style: TextStyle(
                                        color: Colors.grey
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        DividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(applicants.toString(),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18
                              ),
                            ),
                            SizedBox(width: 6,),
                            Text('Applicants',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18
                              ),
                            ),
                            SizedBox(width: 10,),
                            Icon(Icons.how_to_reg_sharp, color: Colors.grey,)
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid != widget.uploadedBy
                        ? Container()
                         : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DividerWidget(),
                            const Text('Recruitment',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: (){
                                       User? user = _auth.currentUser;
                                       final _uid = user!.uid;
                                       if(_uid == widget.uploadedBy){
                                         try {
                                           FirebaseFirestore.instance
                                               .collection('jobs')
                                               .doc(widget.jobId)
                                               .update({'recruitment' : true});
                                         }
                                         catch(error){
                                           GlobalMethod.showErrorDialog(error: 'Action Cannot be performed', context: context);
                                         }
                                       }
                                       else {
                                         GlobalMethod.showErrorDialog(error: 'you Cannot perform this action', context: context);
                                       }
                                       getJobData();
                                    },
                                    child: const Text('ON',
                                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black,
                                      fontSize: 18, fontWeight: FontWeight.normal),
                                    )
                                ),
                                Opacity(
                                    opacity: recruitment==true ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 40,),
                                TextButton(
                                    onPressed: (){
                                      User? user = _auth.currentUser;
                                      final _uid = user!.uid;
                                      if(_uid == widget.uploadedBy){
                                        try {
                                          FirebaseFirestore.instance
                                              .collection('jobs')
                                              .doc(widget.jobId)
                                              .update({'recruitment' : false});
                                        }
                                        catch(error){
                                          GlobalMethod.showErrorDialog(error: 'Action Cannot be performed', context: context);
                                        }
                                      }
                                      else {
                                        GlobalMethod.showErrorDialog(error: 'you Cannot perform this action', context: context);
                                      }
                                      getJobData();
                                    },
                                    child: const Text('OFF',
                                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black,
                                          fontSize: 18, fontWeight: FontWeight.normal),
                                    )
                                ),
                                Opacity(
                                  opacity: recruitment==false ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        DividerWidget(),
                        const Text('Job Description',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(jobDescription==null ?'' :jobDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 14
                          ),
                        ),
                        DividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: Text(
                              isDeadlineAvailable
                              ? 'Actively Recruiting, send CV/Resume'
                              : 'Deadline passed away.',
                            style: TextStyle(
                              color: isDeadlineAvailable ? Colors.green : Colors.red
                            ),
                          ),
                        ),
                        SizedBox(height: 6,),
                        Center(
                          child: MaterialButton(
                            onPressed: (){
                              applyForJob();
                            },
                            color: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Easy apply now',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        DividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Uploaded on : ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              postedDate==null ?'' :postedDate!,
                              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Deadline date : ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              deadlineDate==null ?'' :deadlineDate!,
                              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        DividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                            child: _isCommenting
                            ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: TextField(
                                    controller: _commentController,
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 100,
                                    minLines: 6,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                       filled: true,
                                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white)
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.pink)
                                      )
                                    ),
                                  ),
                                ),
                                Flexible(
                                    child: Column(
                                  children: [
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: MaterialButton(
                                      onPressed: () async {
                                        if(_commentController.text.length < 7){
                                          GlobalMethod.showErrorDialog(error: 'Comment connot be less than 7 characters', context: context);
                                        }
                                        else {
                                          final _generatedId = const Uuid().v4();
                                          await FirebaseFirestore.instance
                                           .collection('jobs')
                                            .doc(widget.jobId)
                                            .update({
                                            'jobComments' : FieldValue.arrayUnion([{
                                              'userId' : FirebaseAuth.instance.currentUser!.uid,
                                              'commentId' : _generatedId,
                                              'name' : name, //authorName,
                                              'userImageurl' : userImage, //userImageUrl
                                              'commentBody' : _commentController.text,
                                              'time' : Timestamp.now()
                                            }])
                                          });
                                          await Fluttertoast.showToast(
                                              msg: 'Comment has been added',
                                              toastLength: Toast.LENGTH_LONG,
                                              backgroundColor: Colors.grey,
                                              fontSize: 18.0
                                          );
                                          _commentController.clear();
                                          setState(() {
                                            showComment = true;
                                          });
                                        }
                                      },
                                      color: Colors.blueAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Text(
                                        'Post',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                    ),
                                    TextButton(
                                        onPressed: (){
                                          setState(() {
                                            _isCommenting = !_isCommenting;
                                            showComment = false;
                                          });
                                        },
                                        child: const Text(
                                          'Cancel'
                                        )
                                    )
                                  ],
                                )
                                )
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _isCommenting = !_isCommenting;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add_comment,
                                      color: Colors.blueAccent,
                                      size: 40,
                                    )
                                ),
                                SizedBox(width: 10,),
                                IconButton(
                                    onPressed: (){
                                      setState(() {
                                        showComment = !showComment;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: Colors.blueAccent,
                                      size: 40,
                                    )
                                ),
                              ],
                            )
                          ),
                           //show comments
                         showComment == false
                          ? Container()
                          : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get(),
                                builder: (context, snapshot){
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  else if(snapshot.data == null){
                                    return Center(
                                      child: Text('No comments in this job'),
                                    );
                                  }

                                  return ListView.separated(
                                    shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index){
                                        return CommentWidget(
                                            commentId: snapshot.data!['jobComments'][index]['commentId'],
                                            commenterId: snapshot.data!['jobComments'][index]['userId'],
                                            commenterName: snapshot.data!['jobComments'][index]['name'],
                                            commentBody: snapshot.data!['jobComments'][index]['commentBody'],
                                            commenterImageUrl: snapshot.data!['jobComments'][index]['userImageurl']
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                         return Divider(
                                           thickness: 1,
                                           color: Colors.grey,
                                         );
                                      },
                                      itemCount: snapshot.data!['jobComments'].length
                                  );
                                }
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
