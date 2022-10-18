
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_recrutement/Services/global_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../Services/global_variables.dart';
import '../SignupPage/signup_screen.dart';
import '../widgets/user_state.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {

  late Animation<double> _animation;
  late AnimationController _animationController;

  final _loginFormKey = GlobalKey<FormState>();
  FocusNode _passFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');
  bool _obscureText = true;
  bool _isLoading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _animationController.dispose();
    _passFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  void _submitFormLogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    if(isValid){
      setState(() {
        _isLoading = true;
      });
      try {
        await auth.signInWithEmailAndPassword(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text.trim()
        );
        Navigator.canPop(context) ? Navigator.pop(context) : null;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>UserState()));
      }
      on FirebaseAuthException catch (e) {
        print('Firebase error : ${e.toString()}');
        GlobalMethod.showErrorDialog(error: e.toString(), context: context);
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

  @override
  Widget build(BuildContext context) {
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
                      'assets/images/login.png',
                    ),
                  ),
                  SizedBox(height: 15,),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_passFocusNode),
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
                          keyboardType: TextInputType.text,
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
                        SizedBox(height: 15,),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: (){
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordScreen()));
                            },
                            child: Text('Forget password',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontStyle: FontStyle.italic),),
                          ),
                        ),
                        SizedBox(height: 10,),
                        _isLoading
                            ? Center(
                          child: Container(
                            height: 70,
                            width: 70,
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : MaterialButton(
                            onPressed: _submitFormLogin,
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
                                  Text('Login', style: TextStyle(color: Colors.white,
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
                                      text: 'Do not have an account?',
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
                                            MaterialPageRoute(builder: (context)=> SignupPage())),
                                    text: 'Signup',
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
}
