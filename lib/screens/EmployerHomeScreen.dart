import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/screens/CoinShopScreen.dart';
import 'package:softezi_flutter/screens/CompanyListScreen.dart';
import 'package:softezi_flutter/screens/CreateCorrectionScreen.dart';
import 'package:softezi_flutter/screens/EmployeeListScreen.dart';
import 'package:softezi_flutter/screens/ProjectListScreen.dart';
import 'package:softezi_flutter/screens/SettingsScreen.dart';

class EmployerHomeScreen extends StatefulWidget {
  @override
  _EmployerHomeScreenState createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    AuthUser user = BlocProvider.of<AuthBloc>(context).state.user;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Home'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            if (user.role == 'employer') ...[
              PageLink(
                  label: 'Sites',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectListScreen()));
                  }),
              SizedBox(height: 10),
              PageLink(
                  label: 'Employee',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmployeeListScreen()));
                  }),
              SizedBox(height: 10),
              PageLink(
                  label: 'Shop',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CoinShopScreen()));
                  }),
              SizedBox(height: 10),
              PageLink(label: 'Correction Requests', onTap: () {}),
            ] else ...[
              PageLink(
                  label: 'Companies',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CompanyListScreen()));
                  }),
              SizedBox(height: 10),
              PageLink(label: 'Set Tax', onTap: () {}),
              SizedBox(height: 10),
              PageLink(label: 'Send Reason for Leave', onTap: () {}),
              SizedBox(height: 10),
              PageLink(
                  label: 'Correction',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateCorrectionScrenn()));
                  }),
            ],
            SizedBox(height: 10),
            PageLink(
                label: 'Settings',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsScreen()));
                }),
          ],
        ),
      ),
    );
  }
}

class PageLink extends StatelessWidget {
  final String label;
  final void Function() onTap;

  const PageLink({
    Key key,
    @required this.label,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white10,
        ),
        width: double.maxFinite,
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.chevron_right_outlined,
              color: Colors.white,
              size: 16,
            )
          ],
        ),
      ),
    );
  }
}
