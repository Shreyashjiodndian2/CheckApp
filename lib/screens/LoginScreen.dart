import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/screens/EmployerHomeScreen.dart';
import 'package:softezi_flutter/screens/RegisterScreen.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _logingUser = false;

  _loginUser() async {
    if (_loginFormKey.currentState.validate()) {
      try {
        setState(() {
          _logingUser = true;
        });
        UserCredential loggedinUser =
            await firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.value.text,
          password: _passwordController.value.text,
        );

        QueryDocumentSnapshot user = await firebaseFirestore
            .collection('employer')
            .where('auth_id', isEqualTo: loggedinUser.user.uid)
            .limit(1)
            .get()
            .then((value) => value.docs.first);

        await setLoggedInUser(
          context,
          authId: user.id,
          id: loggedinUser.user.uid,
          name: loggedinUser.user.displayName,
          role: user.data()['role'],
          email: loggedinUser.user.email,
          companyId: user.data()['company_id'],
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => EmployerHomeScreen(),
          ),
          (route) => false,
        );
      } catch (error) {
        String message = getExceptionMessage(error);
        Toast.show(
          message,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.red,
        );
      }
      setState(() {
        _logingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212128),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Container(
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 50),
                TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  style: TextStyle(color: Colors.white),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white10,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  cursorColor: Theme.of(context).primaryColor,
                  style: TextStyle(color: Colors.white),
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white10,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: _logingUser
                        ? null
                        : () {
                            _loginUser();
                          },
                    child: _logingUser
                        ? Container(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                SizedBox(height: 50),
                Column(
                  children: [
                    Text(
                      'Create new account',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.maxFinite,
                      child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ));
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 16),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

getExceptionMessage(e) {
  String message;

  if (e is FirebaseAuthException) {
    switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        message = "Your email address appears to be malformed.";
        break;
      case "wrong-password":
        message = "Your password is wrong.";
        break;
      case "user-not-found":
        message = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        message = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        message = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        message = "Signing in with Email and Password is not enabled.";
        break;
      case "email-already-in-use":
        message =
            "The email has already been registered. Please login or reset your password.";
        break;
      default:
        message = "An undefined Error happened.";
    }
  } else {
    message = "An undefined Error happened.";
    print("Error -> ${e.toString()}");
  }

  return message;
}
