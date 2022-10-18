import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/Persistent/persistent.dart';
import 'package:e_recrutement/Services/global_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../Services/global_variables.dart';
import '../widgets/bottom_nav_bar.dart';

class UploadJobNow extends StatefulWidget {
  const UploadJobNow({Key? key}) : super(key: key);

  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _jobCategoryController = TextEditingController(text: 'Select Job Category');
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _jobDescriptionController = TextEditingController();
  TextEditingController _deadlineDateController = TextEditingController(text: 'Select Deadline Date');

  bool _isLoading = false;
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;

  Widget _textTitles({required String label}){
      return Padding(
          padding: EdgeInsets.all(5.0),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
      );
  }
  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function function,
    required int maxLength
  }) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: (){
          function();
        },
        child: TextFormField(
          validator: (value){
            if(value!.isEmpty){
              return 'Field is required';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(
            color: Colors.white
          ),
          minLines: valueKey == 'jobDescription' ? 3 : 1,
          maxLines: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)
            ),
            errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red)
            ),
          ),
        ),
      ),
    );
  }

  _showtaskCategoriesDialog({required Size size}) {
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
                          _jobCategoryController.text = Persistent.jobCategoryList[index];
                        });
                        Navigator.pop(context);
                      },
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
                    );
                  }),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  )
              )
            ],
          );
    }
    ) ;
  }

  void _pickDateDialog() async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime(2100)
    );
    if(picked != null){
      _deadlineDateController.text = '${picked!.year}-${picked!.month}-${picked!.day}';
      deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
    }
  }

  _saveTask() async {
    final jobId = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();
    if(isValid){
      if(_deadlineDateController.text == 'Select Deadline Date' || _jobCategoryController.text == 'Select Job Category'){
           GlobalMethod.showErrorDialog(error: 'Please pick everything', context: context);
           return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        /*
         firestoreInstance.collection("users").add(
          {
            "name" : "john",
            "age" : 50,
            "email" : "example@example.com",
            "address" : {
              "street" : "street 24",
              "city" : "new york"
            }
          }).then((value){
            print(value.id);
          });
         */
        await FirebaseFirestore.instance.collection('jobs').doc(jobId)
            .set({
                'jobId' : jobId,
                'uploadedBy' : _uid,
                'email' : user.email,
                'jobTitle' : _jobTitleController.text,
                'jobDescription' : _jobDescriptionController.text,
                'deadlineDate' : _deadlineDateController.text,
                'deadlineDateTimeStamp' : deadlineDateTimeStamp,
                'jobCategory' : _jobCategoryController.text,
                'jobComments' : [],
                'recruitment' : true,
                'createdAt' : Timestamp.now(),
                'name' : name,
                'userImage' : userImage,
                'location' : location,
                'applicants' : 0
             }).then((value) {
               debugPrint('Data upload successfully');
        }).onError((error, stackTrace) async {
          debugPrint('stackTrace : ${stackTrace.toString()}');
          await Fluttertoast.showToast(
              msg: error.toString(),
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.red,
              fontSize: 18.0
          );
        });

        await Fluttertoast.showToast(
            msg: 'Data upload successfully',
           toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0
        );

        _jobTitleController.clear();
        _jobDescriptionController.clear();
        setState(() {
          _jobCategoryController.text = 'Choose job category';
          _deadlineDateController.text = 'Choose job deadline date';
        });
      }
      catch(Exception){
        GlobalMethod.showErrorDialog(error: 'Exception : $Exception', context: context);
        setState(() {
          _isLoading = false;
        });
      }
      finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    else {
      GlobalMethod.showErrorDialog(error: 'Data not valid', context: context);
    }
  }

  /* _getCurrentUser() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid).get();

    setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
      location = userDoc.get('location');
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }*/

  @override
  void dispose() {
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _deadlineDateController.dispose();
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
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2),
        backgroundColor: Colors.transparent,
       /* appBar: AppBar(
          title: const Text('Upload Job'),
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
          child: Padding(
            padding: EdgeInsets.all(7.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.0,),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(7.0),
                        child: Text('Please fill all fields',
                        style: TextStyle(color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Signatra'),),
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    const Divider(thickness: 1,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _textTitles(label: 'Job Category : '),
                              _textFormFields(
                                  valueKey: 'JobCategory',
                                  controller: _jobCategoryController,
                                  enabled: false,
                                  function: (){
                                    _showtaskCategoriesDialog(size: size);
                                  },
                                  maxLength: 100
                              ),

                              _textTitles(label: 'Job Title : '),
                              _textFormFields(
                                  valueKey: 'JobTitle',
                                  controller: _jobTitleController,
                                  enabled: true,
                                  function: (){},
                                  maxLength: 100
                              ),

                              _textTitles(label: 'Job Description : '),
                              _textFormFields(
                                  valueKey: 'jobDescription',
                                  controller: _jobDescriptionController,
                                  enabled: true,
                                  function: (){},
                                  maxLength: 100
                              ),

                              _textTitles(label: 'Job Deadline Date : '),
                              _textFormFields(
                                  valueKey: 'Deadline',
                                  controller: _deadlineDateController,
                                  enabled: false,
                                  function: (){
                                    _pickDateDialog();
                                  },
                                  maxLength: 100
                              ),
                            ],
                          )
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: _isLoading
                            ? Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          ),
                        )
                            : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                              child: MaterialButton(
                              onPressed: (){
                                _saveTask();
                              },
                              color: Colors.black,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Save', style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 25,
                                    fontFamily: 'Signatra'),),
                                    SizedBox(width: 5.0,),
                                    Icon(Icons.upload_file, color: Colors.white,)
                                  ],
                                ),
                              )
                        ),
                            ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
