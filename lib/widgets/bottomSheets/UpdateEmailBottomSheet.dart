import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:softezi_flutter/utils/globals.dart';

class UpdateEmailBottomSheet extends StatefulWidget {
  final String employerId;
  final String currentValue;
  final GlobalKey<ScaffoldState> scaffoldStateKey;

  const UpdateEmailBottomSheet(
      {Key key,
      @required this.employerId,
      @required this.currentValue,
      @required this.scaffoldStateKey})
      : super(key: key);

  @override
  _UpdateEmailBottomSheetState createState() => _UpdateEmailBottomSheetState();
}

class _UpdateEmailBottomSheetState extends State<UpdateEmailBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailControler = TextEditingController();
  bool updating = false;

  @override
  void initState() {
    super.initState();
    _emailControler = TextEditingController(text: widget.currentValue);
  }

  _updateEmail() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        updating = true;
      });

      try {
        await firebaseAuth.currentUser.updateEmail(_emailControler.value.text);
        await firebaseFirestore
            .collection('employer')
            .doc(widget.employerId)
            .update({'email': _emailControler.value.text});
        Navigator.pop(context, _emailControler.value.text);
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
        Navigator.pop(context);
      }
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
              'Update Email',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: _emailControler,
              autofocus: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Email',
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
                onPressed: updating
                    ? null
                    : () {
                        _updateEmail();
                      },
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
