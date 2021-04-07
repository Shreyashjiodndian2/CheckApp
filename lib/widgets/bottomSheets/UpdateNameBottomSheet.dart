import 'package:flutter/material.dart';
import 'package:softezi_flutter/utils/globals.dart';

class UpdateNameBottomSheet extends StatefulWidget {
  final String employerId;
  final String currentValue;

  const UpdateNameBottomSheet(
      {Key key, @required this.employerId, @required this.currentValue})
      : super(key: key);

  @override
  _UpdateNameBottomSheetState createState() => _UpdateNameBottomSheetState();
}

class _UpdateNameBottomSheetState extends State<UpdateNameBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textInputControler = TextEditingController();
  bool updating = false;

  @override
  void initState() {
    super.initState();
    _textInputControler = TextEditingController(text: widget.currentValue);
  }

  _update() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        updating = true;
      });

      await firebaseAuth.currentUser
          .updateProfile(displayName: _textInputControler.value.text);
      await firebaseFirestore
          .collection('employer')
          .doc(widget.employerId)
          .update({'name': _textInputControler.value.text});

      // if (mounted) {
      //   setState(() {
      //     updating = false;
      //   });
      // }
      Navigator.pop(context, _textInputControler.value.text);
    }
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
              'Update Name',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: _textInputControler,
              autofocus: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Name',
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
