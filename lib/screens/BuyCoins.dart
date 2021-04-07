import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nanoid/nanoid.dart' as nanoid;
import 'package:softezi_flutter/bloc/bloc/auth_bloc.dart';
import 'package:softezi_flutter/utils/constants.dart';
import 'package:softezi_flutter/utils/globals.dart';

class BuyCoins extends StatefulWidget {
  @override
  _BuyCoinsState createState() => _BuyCoinsState();
}

class _BuyCoinsState extends State<BuyCoins> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _coinController = TextEditingController();

  bool loading = false;

  _buyCoin(String userId) async {
    setState(() {
      loading = true;
    });
    try {
      int coin = int.parse(_coinController.value.text);
      FocusScope.of(context).unfocus();

      await Future.wait([
        firebaseFirestore
            .collection('employer')
            .doc(userId)
            .update({'coins': FieldValue.increment(coin)}),
        firebaseFirestore.collection('coinTransactions').doc().set({
          'user_id': userId,
          'type': CoinTransactionType.credit,
          'amount': coin,
          'transaction_id': nanoid.customAlphabet('1234567890', 15),
          'timestamp': Timestamp.now(),
        })
      ]);
      _coinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('$coin  coin${coin > 0 ? 's' : ''} added to your wallet.'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Some Error occurred, Try Again.'),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthUser user = BlocProvider.of<AuthBloc>(context).state.user;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Buy Coins'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _coinController,
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  int coin = int.parse(_coinController.value.text);
                  if (coin <= 0) {
                    return 'coin must be greater then 0';
                  }
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false, signed: false),
                decoration: InputDecoration(
                  labelText: 'Coins',
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
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(15)),
                  ),
                  onPressed: loading
                      ? null
                      : () {
                          _buyCoin(user.id);
                        },
                  child: loading
                      ? Container(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text('Buy Coin'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
