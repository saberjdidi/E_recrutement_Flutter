
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/LoginPage/login_screen.dart';
import 'package:e_recrutement/Services/global_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../Services/global_variables.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {

  late Animation<double> _animation;
  late AnimationController _animationController;

  final _signupFormKey = GlobalKey<FormState>();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passFocusNode = FocusNode();
  FocusNode _phoneNumberFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');
  final TextEditingController _phoneNumberController = TextEditingController(text: '');
  final TextEditingController _companyAddressController = TextEditingController(text: '');
  bool _obscureText = true;
  bool _isLoading = false;

  File? imageFile;
  String? imageUrl;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _animationController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _addressFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
      ..addListener(() {
        setState(() {

        });
      })
      ..addStatusListener((animationStatus) {
        if(animationStatus == AnimationStatus.completed){
          _animationController.reset();
          _animationController.forward();
        }
      });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: signupUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 80, right: 80),
                    child: Image.asset(
                      'assets/images/signup.png',
                    ),
                  ),
                  SizedBox(height: 15,),
                  Form(
                    key: _signupFormKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            _showImageDialog();
                          },
                          child: Padding(padding: EdgeInsets.all(8),
                          child: Container(
                            width: 60,//size.width * 24,
                            height: 60,//size.height * 24,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.cyanAccent),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: imageFile == null
                              ? Icon(Icons.camera_enhance_sharp, color: Colors.cyan, size: 30,)
                              : Image.file(imageFile!, fit: BoxFit.fill,)
                              ,
                            ),
                          ),),
                        ),
                        SizedBox(height: 20,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_nameFocusNode),
                          keyboardType: TextInputType.name,
                          controller: _nameController,
                          validator: (value){
                            if(value!.isEmpty){
                              return 'Name is required';
                            }
                            else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'Full name / Company name',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)
                              )
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_emailFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value){
                            if(value!.isEmpty || !value.contains('@')){
                              return 'Please Enter valid email';
                            }
                            else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)
                              )
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _passFocusNode,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          obscureText: !_obscureText,
                          validator: (value){
                            if(value!.isEmpty || value.length<5){
                              return 'Please Enter valid password';
                            }
                            else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)
                              )
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_phoneNumberFocusNode),
                          keyboardType: TextInputType.phone,
                          controller: _phoneNumberController,
                          validator: (value){
                            if(value!.isEmpty ){
                              return 'Phone number is required';
                            }
                            else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'Phone number',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)
                              )
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_addressFocusNode),
                          keyboardType: TextInputType.text,
                          controller: _companyAddressController,
                          validator: (value){
                            if(value!.isEmpty ){
                              return 'Company address';
                            }
                            else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'Company address',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)
                              )
                          ),
                        ),
                        SizedBox(height: 15,),
                        _isLoading
                        ? Center(
                          child: Container(
                            height: 70,
                            width: 70,
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : MaterialButton(
                            onPressed: _submitFormSignUp,
                            color: Colors.cyan,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Signup', style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold, fontSize: 20),)
                                ],
                              ),
                            )
                        ),
                        SizedBox(height: 40,),
                        Center(
                          child: RichText(
                              text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'Already have an account?',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16
                                        )
                                    ),
                                    TextSpan(text:'   '),
                                    TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Navigator.push(context,
                                              MaterialPageRoute(builder: (context)=> Login())),
                                        text: 'Sign In',
                                        style: TextStyle(
                                            color: Colors.cyan,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16
                                        )
                                    )
                                  ]
                              )
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                     _getFromCamera();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.camera, color: Colors.purple,),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Camera', style: TextStyle(color: Colors.purple),)
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    _getFromGallery();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.image, color: Colors.purple,),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('gallery', style: TextStyle(color: Colors.purple),)
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }
    );
  }
  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    imageFile = File(pickedFile!.path);
    //_cropImage(pickedFile!.path);
    Navigator.pop(context);
  }
  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path);
    //_cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  /*void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 1080,
        maxWidth: 1080
    );
    if(croppedImage != null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  } */

  void _submitFormSignUp() async {
    final isValid = await _signupFormKey.currentState!.validate();
    if(isValid){
      if(imageFile == null){
        GlobalMethod.showErrorDialog(error: 'Please pick an image', context: context);
        return;
      }
      setState(() {
        _isLoading =true;
      });
      try {
        await auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text.trim()
        );
        final User? user = auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance.ref().child('userImages').child(_uid+'.jpg');
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users')
        .doc(_uid).set({
          'id' : _uid,
          'name' : _nameController.text,
          'email' : _emailController.text,
          'userImage' : imageUrl,
          'phoneNumber' : _phoneNumberController.text,
          'location' : _companyAddressController.text,
          'createdAt' : Timestamp.now()
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      }
      catch(exception){
        setState(() {
          _isLoading = false;
        });
        print('exception : ${exception.toString()}');
        GlobalMethod.showErrorDialog(error: exception.toString(), context: context);
      }
      finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}


