import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:softezi_flutter/utils/globals.dart';

class CreateCorrectionScrenn extends StatefulWidget {
  @override
  _CreateCorrectionScrennState createState() => _CreateCorrectionScrennState();
}

class _CreateCorrectionScrennState extends State<CreateCorrectionScrenn> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _arrivalDateController = TextEditingController();
  TextEditingController _leaveDateController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();
  TextEditingController _projectController = TextEditingController();
  String _projectId;

  bool _registeringUser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        // elevation: 0,
        title: Text('Create Correction'),
        // backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: _projectController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                onTap: () async {
                  Map project = await showDialog(
                      context: context,
                      builder: (context) => ProjectSelectionDialog());

                  if (project != null) {
                    _projectController.text =
                        "${project['name']} (${project['company']['name']})";
                    _projectId = project['id'];
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Project',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white10,
                  filled: true,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
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
                style: TextStyle(color: Colors.white),
                controller: _arrivalDateController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                readOnly: true,
                onTap: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now());

                  if (date == null) return;

                  TimeOfDay time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());

                  if (time == null) return;
                  _arrivalDateController.text = DateFormat.yMMMd()
                      .add_jm()
                      .format(DateTime(date.year, date.month, date.day,
                          time.hour, time.minute));
                },
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Arrival Time',
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
                style: TextStyle(color: Colors.white),
                controller: _startDateController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now());
                  if (date == null) return;
                  TimeOfDay time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (time == null) return;
                  _startDateController.text = DateFormat.yMMMd()
                      .add_jm()
                      .format(DateTime(date.year, date.month, date.day,
                          time.hour, time.minute));
                },
                decoration: InputDecoration(
                  labelText: 'Start Job Time',
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
                style: TextStyle(color: Colors.white),
                controller: _endDateController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now());
                  if (date == null) return;
                  TimeOfDay time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (time == null) return;
                  _endDateController.text = DateFormat.yMMMd().add_jm().format(
                      DateTime(date.year, date.month, date.day, time.hour,
                          time.minute));
                },
                decoration: InputDecoration(
                  labelText: 'End Job Time',
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
                style: TextStyle(color: Colors.white),
                controller: _leaveDateController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now());
                  if (date == null) return;
                  TimeOfDay time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (time == null) return;
                  _leaveDateController.text = DateFormat.yMMMd()
                      .add_jm()
                      .format(DateTime(date.year, date.month, date.day,
                          time.hour, time.minute));
                },
                decoration: InputDecoration(
                  labelText: 'Leave Job Time',
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
                style: TextStyle(color: Colors.white),
                controller: _reasonController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                maxLines: 5,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Reason',
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
                  onPressed: _registeringUser
                      ? null
                      : () {
                          if (_formKey.currentState.validate()) {}
                        },
                  child: _registeringUser
                      ? Container(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit Correction',
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

class ProjectSelectionDialog extends StatefulWidget {
  @override
  _ProjectSelectionDialogState createState() => _ProjectSelectionDialogState();
}

class _ProjectSelectionDialogState extends State<ProjectSelectionDialog> {
  bool loading = true;

  List<Map> _projectsList;

  @override
  void initState() {
    super.initState();

    loading = true;

    _getProjectList().then((projects) {
      setState(() {
        _projectsList = projects;
        loading = false;
      });
    });
  }

  Future<List<Map>> _getProjectList() async {
    var projects = await firebaseFirestore.collection('projects').get().then(
        (value) => value.docs
            .map((project) => firebaseFirestore
                .collection('company')
                .doc(project.data()['company_id'])
                .get()
                .then((company) => {
                      ...project.data(),
                      'id': project.id,
                      'company': {
                        ...company.data(),
                        'id': company.id,
                      }
                    }))
            .toList());

    return await Future.wait(projects);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 25),
              child: Text(
                'Select Project',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (loading)
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    ..._projectsList.map((project) => ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          title: Text(project['name']),
                          subtitle: Text(
                            project['company']['name'],
                            style: TextStyle(color: Colors.black54),
                          ),
                          onTap: () {
                            Navigator.pop(context, project);
                          },
                        ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
