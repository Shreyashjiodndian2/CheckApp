import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/screens/LoginScreen.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:softezi_flutter/widgets/bottomSheets/UpdateEmailBottomSheet.dart';
import 'package:softezi_flutter/widgets/bottomSheets/UpdateNameBottomSheet.dart';
import 'package:softezi_flutter/widgets/bottomSheets/UpdatePasswordBottomSheet.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Map _userProfile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    setState(() {
      loading = true;
    });
    var employer = await getEmployer();

    setState(() {
      _userProfile = {
        'id': employer['id'],
        'name': employer['name'],
        'email': employer['email'],
        'company': employer['company_id'],
      };
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthUser user = BlocProvider.of<AuthBloc>(context).state.user;

    return Scaffold(
      key: scaffoldKey,
      // backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        // elevation: 0,
        title: Text('Settings'),
        // backgroundColor: Colors.transparent,
      ),
      body: loading
          ? LinearProgressIndicator()
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileDataGroupHeader(label: 'Profile'),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        ProfileDataField(
                          label: 'Name',
                          value: _userProfile['name'],
                          borderBottom: true,
                          onTap: () async {
                            String updateName = await showModalBottomSheet(
                              context: context,
                              elevation: 5,
                              isScrollControlled: true,
                              builder: (context) => UpdateNameBottomSheet(
                                  currentValue: _userProfile['name'],
                                  employerId: _userProfile['id']),
                            );

                            if (updateName != null) {
                              scaffoldKey.currentState.showSnackBar(SnackBar(
                                duration: Duration(seconds: 4),
                                content: Text(
                                  'Name Updated',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));

                              setState(() {
                                _userProfile['name'] = updateName;
                              });
                            }
                          },
                        ),
                        ProfileDataField(
                          label: 'Email',
                          value: _userProfile['email'],
                          borderBottom: user.role == 'employer' ? true : false,
                          onTap: () async {
                            String updateEmail = await showModalBottomSheet(
                              context: context,
                              elevation: 5,
                              isScrollControlled: true,
                              builder: (context) => UpdateEmailBottomSheet(
                                currentValue: _userProfile['email'],
                                employerId: _userProfile['id'],
                                scaffoldStateKey: scaffoldKey,
                              ),
                            );
                            if (updateEmail != null) {
                              scaffoldKey.currentState.showSnackBar(SnackBar(
                                duration: Duration(seconds: 4),
                                content: Text(
                                  'Email Updated',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));

                              setState(() {
                                _userProfile['email'] = updateEmail;
                              });
                            }
                          },
                        ),
                        if (user.role == 'employer')
                          ProfileDataField(
                            label: 'Company',
                            value: _userProfile['company'],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  ProfileDataGroupHeader(label: 'Password'),
                  SizedBox(height: 20),
                  Container(
                    width: double.maxFinite,
                    child: RaisedButton(
                      elevation: 0,
                      color: Colors.white10,
                      padding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      textColor: Colors.white,
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          elevation: 5,
                          isScrollControlled: true,
                          builder: (context) => UpdatePasswordBottomSheet(
                            scaffoldStateKey: scaffoldKey,
                          ),
                        );
                      },
                      child: Text('Change Password'),
                    ),
                  ),
                  SizedBox(height: 40),
                  ProfileDataGroupHeader(label: 'Account'),
                  SizedBox(height: 20),
                  Container(
                    width: double.maxFinite,
                    child: OutlineButton(
                      padding: EdgeInsets.all(20),
                      borderSide: BorderSide(
                        color: Colors.white70,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      textColor: Colors.white70,
                      onPressed: () async {
                        await firebaseAuth.signOut();
                        await Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) => false);
                      },
                      child: Text('Logout'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class ProfileDataGroupHeader extends StatelessWidget {
  final String label;

  const ProfileDataGroupHeader({
    Key key,
    @required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }
}

class ProfileDataField extends StatelessWidget {
  final String label;
  final String value;
  final bool borderBottom;
  final void Function() onTap;

  const ProfileDataField({
    Key key,
    @required this.label,
    @required this.value,
    this.onTap,
    this.borderBottom = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: borderBottom ? EdgeInsets.only(bottom: 10) : null,
      margin: borderBottom ? EdgeInsets.only(bottom: 10) : null,
      decoration: BoxDecoration(
        border: borderBottom
            ? Border(
                bottom: BorderSide(
                  color: Colors.white24,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              // fontSize: 16,
              color: Colors.white,
            ),
          ),
          Container(
            padding: onTap == null ? EdgeInsets.symmetric(vertical: 16) : null,
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value,
                    softWrap: true,
                    style: TextStyle(
                      // fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
                if (onTap != null)
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.white38,
                    ),
                    onPressed: onTap,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
