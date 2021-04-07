import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/utils/constants.dart';
import 'package:softezi_flutter/utils/globals.dart';

class AddNewEmployeeListScreen extends StatefulWidget {
  @override
  _AddNewEmployeeListScreenState createState() =>
      _AddNewEmployeeListScreenState();
}

class _AddNewEmployeeListScreenState extends State<AddNewEmployeeListScreen> {
  Map _company;
  bool loading;

  @override
  initState() {
    super.initState();
    loading = true;
    _getCompanyData().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  Future _getCompanyData() async {
    AuthUser user = BlocProvider.of<AuthBloc>(this.context).state.user;

    _company = await firebaseFirestore
        .collection('company')
        .where('created_by', isEqualTo: user.id)
        .limit(1)
        .get()
        .then((value) => value.docs.first)
        .then((value) => {...value.data(), 'id': value.id});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: Text('Add Employee'),
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            tabs: [
              Tab(child: Text('All Employees')),
              Tab(child: Text('Employees Requests')),
            ],
          ),
        ),
        body: loading
            ? LinearProgressIndicator()
            : TabBarView(
                children: [
                  AllEmployeeTabPage(
                    company: _company,
                  ),
                  AllEmployeeTabPage(
                    company: _company,
                    showEmployeesRequests: true,
                  ),
                ],
              ),
      ),
    );
  }
}

class AllEmployeeTabPage extends StatefulWidget {
  final Map company;
  final bool showEmployeesRequests;

  const AllEmployeeTabPage(
      {Key key, @required this.company, this.showEmployeesRequests = false})
      : super(key: key);

  @override
  _AllEmployeeTabPageState createState() => _AllEmployeeTabPageState();
}

class _AllEmployeeTabPageState extends State<AllEmployeeTabPage> {
  bool loading = false;
  List<Map> _employeesList = [];

  @override
  initState() {
    super.initState();

    loading = true;

    (widget.showEmployeesRequests ? _getRequests() : _getEmployees())
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  _getRequests() async {
    var requests = await firebaseFirestore
        .collection('joinRequests')
        .where('to', isEqualTo: widget.company['id'])
        .where('status', isEqualTo: 'pending')
        .get()
        .then((value) => value.docs)
        .then((value) => value
            .map((request) => firebaseFirestore
                .collection('employer')
                .doc(request.data()['from'])
                .get()
                .then((e) => {
                      ...e.data(),
                      'id': e.id,
                      'requestId': request.id,
                    }))
            .toList());

    _employeesList = await Future.wait(requests);
  }

  Future<void> _getEmployees() async {
    var _employeesInvited = await firebaseFirestore
        .collection('joinRequests')
        .where('from', isEqualTo: widget.company['id'])
        .where('status', isEqualTo: 'pending')
        .get()
        .then((value) => value.docs)
        .then((value) => value.map((e) => e.id).toList());

    _employeesList = await firebaseFirestore
        .collection('employer')
        .where('role', isEqualTo: 'employee')
        .get()
        .then((value) => value.docs
            .where((element) => !_employeesInvited.contains(element.id))
            .map((e) => {
                  ...e.data(),
                  'id': e.id,
                })
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TODO: Search input
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
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
              'No Employee to add',
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
                    trailing: widget.showEmployeesRequests
                        ? DecisionButtonGroup(
                            requestId: _employeesList[i]['requestId'],
                            userId: _employeesList[i]['id'],
                            companyid: widget.company['id'],
                            onDecision: () {
                              setState(() {
                                _employeesList.removeAt(i);
                              });
                            },
                          )
                        : InviteButton(
                            userId: _employeesList[i]['id'],
                            companyid: widget.company['id'],
                            onInvite: () {
                              setState(() {
                                _employeesList.removeAt(i);
                              });
                            },
                          ),
                  )
                }
              ],
            ),
          ),
      ],
    );
  }
}

class InviteButton extends StatefulWidget {
  final String userId;
  final String companyid;
  final void Function() onInvite;

  const InviteButton(
      {Key key, @required this.userId, @required this.companyid, this.onInvite})
      : super(key: key);

  @override
  _InviteButtonState createState() => _InviteButtonState();
}

class _InviteButtonState extends State<InviteButton> {
  bool loading = false;

  Future<void> _joinRequest(String companyId, String userId) async {
    setState(() {
      loading = true;
    });

    Timestamp timestamp = Timestamp.now();
    await firebaseFirestore.collection('joinRequests').doc().set({
      'from': companyId,
      'to': userId,
      'request_type': JoinRequestType.companyToEmployee,
      'status': 'pending',
      'timestamp': timestamp,
    });

    if (widget.onInvite != null) {
      widget.onInvite();
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: loading
          ? Container(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Text('Invite'),
      onPressed: loading
          ? null
          : () async {
              await _joinRequest(widget.companyid, widget.userId);
            },
    );
  }
}

class DecisionButtonGroup extends StatefulWidget {
  final String requestId;
  final String userId;
  final String companyid;
  final void Function() onDecision;

  const DecisionButtonGroup(
      {Key key,
      this.onDecision,
      @required this.requestId,
      @required this.companyid,
      this.userId})
      : super(key: key);

  @override
  _DecisionButtonGroupState createState() => _DecisionButtonGroupState();
}

class _DecisionButtonGroupState extends State<DecisionButtonGroup> {
  bool loading = false;

  Future<void> _submitDecision(DecisionType decision) async {
    setState(() {
      loading = true;
    });

    await Future.wait([
      firebaseFirestore
          .collection('joinRequests')
          .doc(widget.requestId)
          .update({
        'status': decision == DecisionType.accept ? 'accept' : 'reject',
      }),
      if (decision == DecisionType.accept)
        firebaseFirestore
            .collection('company')
            .doc(widget.companyid)
            .collection('employees')
            .add({
          'user_id': widget.userId,
          'start_date': Timestamp.now(),
          'end_date':
              Timestamp.fromDate(DateTime.now().add(Duration(days: 31))),
          'timestamp': Timestamp.now(),
        })
    ]);

    if (widget.onDecision != null) {
      widget.onDecision();
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                child: Text('Reject'),
                onPressed: loading
                    ? null
                    : () async {
                        await _submitDecision(DecisionType.reject);
                      },
              ),
              ElevatedButton(
                child: Text('Accept'),
                onPressed: loading
                    ? null
                    : () async {
                        await _submitDecision(DecisionType.accept);
                      },
              ),
            ],
          );
  }
}
