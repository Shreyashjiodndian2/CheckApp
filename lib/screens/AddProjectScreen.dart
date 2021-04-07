import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:softezi_flutter/modals/LocationInputModal.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:toast/toast.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _newProjectFormKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  Map _locationAddress;

  bool _addingProject = false;

  _addProject() async {
    setState(() {
      _addingProject = true;
    });

    String companyId = await firebaseFirestore
        .collection('employer')
        .where('auth_id', isEqualTo: firebaseAuth.currentUser.uid)
        .get()
        .then((value) => value.docs.first.data()['company_id']);

    await firebaseFirestore.collection('projects').doc().set({
      'name': _nameController.value.text,
      'location': _locationAddress,
      'company_id': companyId,
      'timestamp': Timestamp.now(),
    });

    _newProjectFormKey.currentState.reset();
    Toast.show('Project Added', context,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: Toast.BOTTOM,
        backgroundRadius: 8,
        duration: Toast.LENGTH_LONG);
    setState(() {
      _addingProject = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Add Project'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _newProjectFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextFormField(
                cursorColor: Theme.of(context).primaryColor,
                style: TextStyle(color: Colors.white),
                controller: _nameController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Project Name',
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
              TextFormField(
                cursorColor: Theme.of(context).primaryColor,
                style: TextStyle(color: Colors.white),
                controller: _locationController,
                readOnly: true,
                onTap: () async {
                  Map location = await showDialog(
                      context: context,
                      builder: (context) => LocationInputModal(
                            addressMap: _locationAddress,
                          ));
                  if (location != null) {
                    _locationController.text = location['addressLine'];
                    _locationAddress = location;
                  }
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Location',
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
                child: RaisedButton(
                  padding: EdgeInsets.all(15),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: _addingProject
                      ? null
                      : () {
                          _addProject();
                        },
                  child: _addingProject
                      ? Container(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Add Project',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
