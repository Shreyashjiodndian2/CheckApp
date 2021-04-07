import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';

import 'package:softezi_flutter/screens/EmployerHomeScreen.dart';
import 'package:softezi_flutter/screens/LoginScreen.dart';
import 'package:softezi_flutter/screens/RegisterScreen.dart';
import 'package:softezi_flutter/utils/globals.dart';

var primaryColor = Color(0xFFDC4F64);
var accentColor = Colors.orange;
var backgroundColor = Color(0xFF212128);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final FirebaseAuth mauth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        title: 'SoftEzi Task',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryColor,
          accentColor: Colors.orange,
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            brightness: Brightness.dark,
          ),
          backgroundColor: backgroundColor,
          scaffoldBackgroundColor: backgroundColor,
          textSelectionTheme: TextSelectionThemeData(cursorColor: primaryColor),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey;
                }
                return primaryColor; // Use the component's default.
              },
            ),
          )),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
                overlayColor: MaterialStateProperty.all<Color>(
                    primaryColor.withOpacity(0.1))),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.all(15)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              side: MaterialStateProperty.all(BorderSide(
                width: 1,
                color: Colors.white24,
              )),
              overlayColor:
                  MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              )),
            ),
          ),
        ),
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Future<FirebaseApp> _firebaseAppInit = Firebase.initializeApp();

  Future _getLoggedInUser() async {
    User loggedInUser = firebaseAuth.currentUser;

    if (loggedInUser != null) {
      QueryDocumentSnapshot user = await firebaseFirestore
          .collection('employer')
          .where('auth_id', isEqualTo: loggedInUser.uid)
          .limit(1)
          .get()
          .then((value) => value.docs.first);

      await setLoggedInUser(
        context,
        id: user.id,
        email: loggedInUser.email,
        authId: loggedInUser.uid,
        name: loggedInUser.displayName,
        role: user.data()['role'],
        companyId: user.data()['company_id'],
      );
    }
  }

  Future _applicationInitialization() async {
    await _firebaseAppInit;
    await _getLoggedInUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Application sartup routine methods:
      future: _applicationInitialization(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          if (isLoggedIn()) {
            return EmployerHomeScreen();
          }

          return LoginScreen();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
