import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

bool isLoggedIn() {
  User user = firebaseAuth.currentUser;
  if (user == null) {
    return false;
  }
  return true;
}

Future<LocationData> getLocation() async {
  PermissionStatus _permission;
  Location _locationService = Location();
  await _locationService.changeSettings(
      accuracy: LocationAccuracy.high, interval: 1000);

  LocationData location;
  bool serviceStatus = await _locationService.serviceEnabled();
  if (serviceStatus) {
    _permission = await _locationService.requestPermission();

    if (_permission == PermissionStatus.granted) {
      location = await _locationService.getLocation();
      return location;
    }

    return null;
  } else {
    bool serviceStatusResult = await _locationService.requestService();

    if (serviceStatusResult) {
      return getLocation();
    } else {
      return null;
    }
  }
}

Future<String> getCompanyId() {
  return firebaseFirestore
      .collection('employer')
      .where('auth_id', isEqualTo: firebaseAuth.currentUser.uid)
      .limit(1)
      .get()
      .then((value) => value.docs.first.data()['company_id']);
}

Future<Map> getEmployer() {
  return firebaseFirestore
      .collection('employer')
      .where('auth_id', isEqualTo: firebaseAuth.currentUser.uid)
      .limit(1)
      .get()
      .then((value) => {'id': value.docs.first.id, ...value.docs.first.data()});
}

Future setLoggedInUser(
  BuildContext context, {
  @required String authId,
  @required String id,
  @required String name,
  @required String role,
  @required String email,
  String companyId,
}) async {
  await BlocProvider.of<AuthBloc>(context).loginUser(AuthUser(
    id: id,
    email: email,
    authId: authId,
    name: name,
    role: role,
    companyId: companyId,
  ));
}
