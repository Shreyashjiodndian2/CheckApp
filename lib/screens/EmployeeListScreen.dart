import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/screens/AddNewEmployeeScreen.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:softezi_flutter/widgets/bottomSheets/ExtendEmployeeBottomSheet.dart';

class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  initState() {
    super.initState();
    _getCompanies();
  }

  bool loading = false;
  List<Map> _employeesList = [];
  Map company;

  Future<void> _getCompanies() async {
    setState(() {
      loading = true;
    });
    AuthUser user = BlocProvider.of<AuthBloc>(this.context).state.user;

    var _company = await firebaseFirestore
        .collection('company')
        .where('created_by', isEqualTo: user.id)
        .limit(1)
        .get()
        .then((value) => value.docs.first)
        .then((value) => {...value.data(), 'id': value.id});

    DateTime currentDate = DateTime.now();
    var list = await firebaseFirestore
        .collection('company')
        .doc(_company['id'])
        .collection('employees')
        .get()
        .then((value) => value.docs
            .map((e) => firebaseFirestore
                .collection('employer')
                .doc(e.data()['user_id'])
                .get()
                .then((value) => {
                      ...value.data(),
                      'start_date': e.data()['start_date'],
                      'end_date': e.data()['end_date'],
                      'expiring_in': (e.data()['end_date'] as Timestamp)
                          .toDate()
                          .difference(currentDate)
                          .inDays,
                      'id': e.id,
                      'user_id': value.id
                    }))
            .toList());

    _employeesList = await Future.wait(list);
    company = _company;

    setState(() {
      loading = false;
    });
  }

  _onPopMenuSelect(String option, int employeeIndex) async {
    switch (option) {
      case 'buy':
        Map employee = _employeesList[employeeIndex];
        DateTime newEndDate = await showModalBottomSheet(
          context: context,
          elevation: 5,
          isScrollControlled: true,
          builder: (context) => ExtendEmployeeBottomSheet(
            companyId: company['id'],
            employee: employee,
          ),
        );

        setState(() {
          _employeesList[employeeIndex]['end_date'] =
              Timestamp.fromDate(newEndDate);
          _employeesList[employeeIndex]['expiring_in'] =
              newEndDate.difference(DateTime.now()).inDays;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Employee'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddNewEmployeeListScreen(),
              ));
            },
          ),
          PopupMenuButton(
            onSelected: (value) {},
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Download as PDF'),
                  value: 'downloadPDF',
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Container(
          //   margin: EdgeInsets.only(top: 15, left: 26, right: 26, bottom: 20),
          //   child: TextField(
          //     style: TextStyle(color: Colors.white),
          //     decoration: InputDecoration(
          //       hintText: 'Search Employee',
          //       hintStyle: TextStyle(color: Colors.white54),
          //       suffixIcon: Icon(
          //         Icons.search,
          //         color: Colors.white,
          //       ),
          //       enabledBorder: UnderlineInputBorder(
          //         borderSide: BorderSide(color: Colors.white70),
          //       ),
          //       // focusedBorder: OutlineInputBorder(
          //       //   borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          //       // ),
          //     ),
          //   ),
          // ),
          if (loading)
            LinearProgressIndicator()
          else if (_employeesList.length == 0)
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              margin: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.025),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                'No Employee',
                style: TextStyle(color: Colors.white30),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  for (var i = 0; i < _employeesList.length; i++) ...{
                    ListTile(
                      title: Text(
                        _employeesList[i]['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${_employeesList[i]['expiring_in']} Day${_employeesList[i]['expiring_in'] > 1 ? 's' : ''} left',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: PopupMenuButton(
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onSelected: (value) => _onPopMenuSelect(value, i),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              child: Text('Buy'),
                              value: 'buy',
                            ),
                            PopupMenuItem(
                              child: Text('Set Taxes'),
                              value: 'setTax',
                            ),
                            PopupMenuItem(
                              child: Text('Correct Request'),
                              value: 'correctRequest',
                            ),
                            PopupMenuItem(
                              child: Text('Delete'),
                              value: 'delete',
                            ),
                          ];
                        },
                      ),
                    )
                  }
                ],
              ),
            ),
        ],
      ),
    );
  }
}
