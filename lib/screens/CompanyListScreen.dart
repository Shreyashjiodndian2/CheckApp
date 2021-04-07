import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/utils/constants.dart';
import 'package:softezi_flutter/utils/globals.dart';

class CompanyListScreen extends StatefulWidget {
  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  @override
  Widget build(BuildContext context) {
    AuthUser user = BlocProvider.of<AuthBloc>(context).state.user;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: Text('Companies'),
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            tabs: [
              Tab(child: Text('All Companies')),
              Tab(child: Text('Companies Initavtions')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllCompanyListTabPage(user: user),
            AllCompanyListTabPage(
              user: user,
              showCompanyInvitations: true,
            ),
          ],
        ),
      ),
    );
  }
}

class AllCompanyListTabPage extends StatefulWidget {
  final AuthUser user;
  final bool showCompanyInvitations;

  const AllCompanyListTabPage(
      {Key key, @required this.user, this.showCompanyInvitations = false})
      : super(key: key);

  @override
  _AllCompanyListTabPageState createState() => _AllCompanyListTabPageState();
}

class _AllCompanyListTabPageState extends State<AllCompanyListTabPage> {
  @override
  initState() {
    super.initState();
    loading = true;

    (widget.showCompanyInvitations ? _getInvitations() : _getCompanies())
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  bool loading = false;
  List<Map> _companiesList = [];

  _getInvitations() async {
    var requests = await firebaseFirestore
        .collection('joinRequests')
        .where('to', isEqualTo: widget.user.id)
        .where('status', isEqualTo: 'pending')
        .get()
        .then((value) => value.docs)
        .then((value) => value
            .map((request) => firebaseFirestore
                .collection('company')
                .doc(request.data()['from'])
                .get()
                .then((e) => firebaseFirestore
                    .collection('company')
                    .doc(e.id)
                    .collection('employees')
                    .get()
                    .then((employeesList) => {
                          ...e.data(),
                          'total_employees': employeesList.size,
                          'id': e.id,
                          'requestId': request.id,
                        })))
            .toList());

    _companiesList = await Future.wait(requests);
  }

  Future<void> _getCompanies() async {
    var _companiesRequested = await firebaseFirestore
        .collection('joinRequests')
        .where('from', isEqualTo: widget.user.id)
        .where('status', isEqualTo: 'pending')
        .get()
        .then((value) => value.docs)
        .then((value) => value.map((e) => e.data()['to']).toList());

    var list = await firebaseFirestore.collection('company').get().then(
        (value) => value.docs
            .where((element) => !_companiesRequested.contains(element.id))
            .map((company) => firebaseFirestore
                .collection('company')
                .doc(company.id)
                .collection('employees')
                .get()
                .then((employeesList) => {
                      ...company.data(),
                      'total_employees': employeesList.size,
                      'id': company.id,
                    }))
            .toList());

    _companiesList = await Future.wait(list);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   margin: EdgeInsets.only(top: 15, left: 26, right: 26, bottom: 20),
        //   child: TextField(
        //     style: TextStyle(color: Colors.white),
        //     decoration: InputDecoration(
        //       hintText: 'Search Company',
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
        else if (_companiesList.length == 0)
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
              'No Company',
              style: TextStyle(color: Colors.white30),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: [
                for (var i = 0; i < _companiesList.length; i++) ...{
                  ListTile(
                    title: Text(
                      _companiesList[i]['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${_companiesList[i]['total_employees']} Employee',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: widget.showCompanyInvitations
                        ? DecisionButtonGroup(
                            requestId: _companiesList[i]['requestId'],
                            companyid: _companiesList[i]['id'],
                            userId: widget.user.id,
                            onDecision: () {
                              setState(() {
                                _companiesList.removeAt(i);
                              });
                            },
                          )
                        : JoinRequestButton(
                            user: widget.user,
                            companyid: _companiesList[i]['id'],
                            onJoined: () {
                              setState(() {
                                _companiesList.removeAt(i);
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

class JoinRequestButton extends StatefulWidget {
  final AuthUser user;
  final String companyid;
  final void Function() onJoined;

  const JoinRequestButton(
      {Key key, @required this.user, @required this.companyid, this.onJoined})
      : super(key: key);

  @override
  _JoinRequestButtonState createState() => _JoinRequestButtonState();
}

class _JoinRequestButtonState extends State<JoinRequestButton> {
  bool loading = false;

  Future<void> _joinRequest(String companyId, String userId) async {
    setState(() {
      loading = true;
    });

    Timestamp timestamp = Timestamp.now();

    await firebaseFirestore
        .collection('joinRequests')
        .where('from', isEqualTo: userId)
        .where('to', isEqualTo: companyId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get()
        .then((value) {
      if (value.size == 0) {
        return firebaseFirestore.collection('joinRequests').doc().set({
          'from': userId,
          'to': companyId,
          'status': 'pending',
          'request_type': JoinRequestType.employeeToCompany,
          'timestamp': timestamp,
        });
      }
    });

    if (widget.onJoined != null) {
      widget.onJoined();
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
          : Text('Join'),
      onPressed: loading
          ? null
          : () async {
              await _joinRequest(widget.companyid, widget.user.id);
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
