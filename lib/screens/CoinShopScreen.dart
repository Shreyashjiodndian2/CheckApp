import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/screens/BuyCoins.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:intl/intl.dart';
import 'package:strings/strings.dart';

class CoinShopScreen extends StatefulWidget {
  @override
  _CoinShopScreenState createState() => _CoinShopScreenState();
}

class _CoinShopScreenState extends State<CoinShopScreen> {
  AuthUser user;
  int coinsBlance;
  List<Map> transactions;
  bool loading;

  @override
  initState() {
    super.initState();
    user = BlocProvider.of<AuthBloc>(context).state.user;

    loading = true;

    Future.wait([
      _getCoins,
      _getTransactions,
    ]).then((response) {
      setState(() {
        coinsBlance = response[0];
        print(response[1]);
        transactions = response[1];
        loading = false;
      });
    });
  }

  Future<int> get _getCoins async {
    return await firebaseFirestore
        .collection('employer')
        .doc(user.id)
        .get()
        .then((value) =>
            value.data()['coins'] != null ? value.data()['coins'] : 0);
  }

  Future<List<Map>> get _getTransactions async {
    return await firebaseFirestore
        .collection('coinTransactions')
        .where('user_id', isEqualTo: user.id)
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) => value.docs)
        .then((value) => value
            .map((e) => {
                  ...e.data(),
                  'timestamp': (e.data()['timestamp'] as Timestamp).toDate(),
                  'id': e.id,
                })
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Coins'),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? LinearProgressIndicator()
          : Container(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccountBalance(coins: coinsBlance),
                  SizedBox(height: 30),
                  Text(
                    'Transtactions',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      // fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                      child: ListView(
                    children: [
                      ...transactions.map((transaction) => ListTile(
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              transaction['transaction_id'],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd()
                                  .add_jm()
                                  .format(transaction['timestamp'])
                                  .toString(),
                              style: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                            trailing: Chip(
                              visualDensity: VisualDensity.compact,
                              elevation: 2,
                              backgroundColor: transaction['type'] == 'credit'
                                  ? Colors.green
                                  : Colors.red,
                              labelStyle: TextStyle(color: Colors.white),
                              // padding: EdgeInsets.all(0),
                              label: Text(capitalize(transaction['type'])),
                            ),
                          ))
                    ],
                  ))
                ],
              ),
            ),
    );
  }
}

class AccountBalance extends StatelessWidget {
  final int coins;

  const AccountBalance({
    Key key,
    @required this.coins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        // fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${coins.toString()} Coin${coins > 0 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white,
                    // fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.maxFinite,
            // margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: Colors.white12,
            ))),
            child: TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => BuyCoins()));
              },
              child: Text('Buy Coins'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).accentColor),
                overlayColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).accentColor.withOpacity(0.1)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
