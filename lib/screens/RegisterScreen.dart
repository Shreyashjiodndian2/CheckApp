import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/screens/LoginScreen.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:toast/toast.dart';

import 'EmployerHomeScreen.dart';

enum RegiterAs { company, employee }

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registerFormKey = GlobalKey<FormState>();

  RegiterAs _tabSelected = RegiterAs.company;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _comapanyController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  bool _registeringUser = false;

  _registerUser() async {
    if (_registerFormKey.currentState.validate()) {
      try {
        setState(() {
          _registeringUser = true;
        });
        UserCredential registeredUser =
            await firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.value.text,
          password: _passwordController.value.text,
        );

        DocumentReference company;

        if (_tabSelected == RegiterAs.company) {
          company = firebaseFirestore.collection('company').doc();
        }

        DocumentReference employer =
            firebaseFirestore.collection('employer').doc();

        Timestamp timestamp = Timestamp.now();

        var userData = {
          'name': _nameController.value.text,
          'email': _emailController.value.text,
          'auth_id': registeredUser.user.uid,
          if (company != null) 'company_id': company.id,
          'role': company != null ? 'employer' : 'employee',
          'timestamp': timestamp,
        };

        await Future.wait([
          employer.set(userData),
          registeredUser.user.updateProfile(displayName: userData['name']),
          if (company != null)
            company.set({
              'created_by': employer.id,
              'name': _comapanyController.value.text,
              'timestamp': timestamp
            })
        ]);

        await setLoggedInUser(
          context,
          id: employer.id,
          email: userData['email'],
          authId: registeredUser.user.uid,
          name: userData['name'],
          role: userData['role'],
          companyId: userData['company_id'],
        );

        await Navigator.pushAndRemoveUntil(
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
        _registeringUser = false;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500),
                  ),
                  ToggleButtons(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('Company'),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('Employee'),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(4),
                    constraints: BoxConstraints(
                      minHeight: double.minPositive,
                      minWidth: double.minPositive,
                    ),
                    borderColor: Colors.white30,
                    color: Colors.white54,
                    selectedColor: Colors.white,
                    fillColor: Colors.white12,
                    selectedBorderColor: Colors.white30,
                    renderBorder: false,
                    isSelected: [
                      _tabSelected == RegiterAs.company ? true : false,
                      _tabSelected == RegiterAs.employee ? true : false,
                    ],
                    borderWidth: 1,
                    onPressed: (index) {
                      setState(() {
                        switch (index) {
                          case 0:
                            _tabSelected = RegiterAs.company;
                            break;
                          case 1:
                            _tabSelected = RegiterAs.employee;
                            break;
                        }
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 50),
              Form(
                key: _registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextFormField(
                      cursorColor: Theme.of(context).primaryColor,
                      style: TextStyle(color: Colors.white),
                      controller: _nameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Field is required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                    if (_tabSelected == RegiterAs.company) ...[
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        style: TextStyle(color: Colors.white),
                        controller: _comapanyController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Field is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Company Name',
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
                      SizedBox(height: 20)
                    ],
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
                        onPressed: _registeringUser
                            ? null
                            : () {
                                _registerUser();
                              },
                        child: _registeringUser
                            ? Container(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                'Register',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Column(
                children: [
                  Text(
                    'Already have a account?',
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
                                builder: (context) => LoginScreen(),
                              ));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

getExceptionMessage(e) {
  String message;
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
  return message;
}
