import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:softezi_flutter/utils/globals.dart';

class UpdatePasswordBottomSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldStateKey;

  const UpdatePasswordBottomSheet({@required this.scaffoldStateKey});

  @override
  _UpdatePasswordBottomSheetState createState() =>
      _UpdatePasswordBottomSheetState();
}

class _UpdatePasswordBottomSheetState extends State<UpdatePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textInputControler = TextEditingController();
  bool updating = false;

  _update() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();

      setState(() {
        updating = true;
      });

      try {
        await firebaseAuth.currentUser
            .updatePassword(_textInputControler.value.text);
        widget.scaffoldStateKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Password Updated',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ));
      } on FirebaseAuthException catch (error) {
        widget.scaffoldStateKey.currentState.showSnackBar(SnackBar(
          elevation: 20,
          duration: Duration(seconds: 4),
          content: Text(
            error.message,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
        top: 30,
        bottom: 30,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Password',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(height: 30),
            TextFormField(
              obscureText: true,
              controller: _textInputControler,
              autofocus: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white12),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.maxFinite,
              child: FlatButton(
                disabledColor: Colors.grey.shade200,
                onPressed: updating ? null : () => _update(),
                padding: EdgeInsets.all(18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: updating
                    ? Container(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.grey),
                        ),
                      )
                    : Text('Update'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
