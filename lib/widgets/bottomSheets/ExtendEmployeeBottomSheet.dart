import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:intl/intl.dart';

class ExtendEmployeeBottomSheet extends StatefulWidget {
  final String companyId;
  final Map employee;

  const ExtendEmployeeBottomSheet(
      {Key key, @required this.companyId, @required this.employee})
      : super(key: key);

  @override
  _ExtendEmployeeBottomSheetState createState() =>
      _ExtendEmployeeBottomSheetState();
}

class _ExtendEmployeeBottomSheetState extends State<ExtendEmployeeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _coinController = TextEditingController();
  StreamController<int> _coinValueStream = StreamController<int>();

  int balance = 0;

  bool updating = false;
  bool loading = true;

  @override
  initState() {
    super.initState();
    loading = true;

    _getWalletBalance().then((coinsBalance) {
      setState(() {
        balance = coinsBalance;
        loading = false;
      });
    });
  }

  Future _ExtendEmployeeTenure() async {
    setState(() {
      updating = true;
    });

    if (_formKey.currentState.validate()) {
      int coins = int.parse(_coinController.value.text);
      DateTime newEndDate = (widget.employee['end_date'] as Timestamp)
          .toDate()
          .add(Duration(days: 31 * coins));
      await firebaseFirestore
          .collection('company')
          .doc(widget.companyId)
          .collection('employees')
          .doc(widget.employee['id'])
          .update({
        'end_date': newEndDate,
        'coins_consumed': FieldValue.increment(coins)
      });

      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '${widget.employee['name']} tenure extend till ${DateFormat.yMMMd().add_jm().format(newEndDate)}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, newEndDate);
    }

    setState(() {
      updating = false;
    });
  }

  Future<int> _getWalletBalance() async {
    String userId = BlocProvider.of<AuthBloc>(context).state.user.id;

    return await firebaseFirestore
        .collection('employer')
        .doc(userId)
        .get()
        .then((value) => value.data()['coins']);
  }

  @override
  dispose() {
    super.dispose();
    _coinValueStream.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Extend Employee',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(height: 30),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        // color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Balance',
                        style: TextStyle(
                          // color: Colors.white,
                          // fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  loading
                      ? Container(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black87),
                          ),
                        )
                      : Text(
                          '${balance.toString()} Coin${balance > 0 ? 's' : ''}',
                          style: TextStyle(
                              // color: Colors.white,
                              // fontSize: 20,
                              ),
                        ),
                ],
              ),
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: _coinController,
              autofocus: true,
              onChanged: (value) {
                try {
                  int coin = int.parse(value);
                  _coinValueStream.add(coin);
                } catch (e) {}
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Field is required';
                }
                try {
                  int coin = int.parse(value);
                  if (coin <= 0) {
                    return 'coin must be greater then 0';
                  }
                  if (coin > balance) {
                    return 'You have only $balance coin${balance > 0 ? 's' : ''} in your wallet';
                  }
                } catch (e) {
                  return 'Invalid value';
                }
                return null;
              },
              keyboardType: TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              decoration: InputDecoration(
                labelText: 'Coins',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white12),
                ),
              ),
            ),
            SizedBox(height: 30),
            StreamBuilder(
              stream: _coinValueStream.stream,
              initialData: 0,
              builder: (context, snapshot) {
                return Text(
                    'Extend Till ${DateFormat.yMMMd().add_jm().format(widget.employee['end_date'].toDate().add(Duration(days: 31 * snapshot.data)))}');
              },
            ),
            SizedBox(height: 30),
            Container(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: updating ? null : () => _ExtendEmployeeTenure(),
                child: updating
                    ? Container(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.grey),
                        ),
                      )
                    : Text('Extend'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
