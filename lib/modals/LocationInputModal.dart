import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:toast/toast.dart';

class LocationInputModal extends StatefulWidget {
  final Map addressMap;

  const LocationInputModal({@required this.addressMap});

  @override
  _LocationInputModalState createState() =>
      _LocationInputModalState(addressMap);
}

class _LocationInputModalState extends State<LocationInputModal> {
  bool fetchingLocation = false;
  final _formKey = GlobalKey<FormState>();

  _LocationInputModalState(addressMap) {
    if (addressMap != null) {
      line1Controller.text = addressMap['line1'];
      line2Controller.text = addressMap['line2'];
      stateController.text = addressMap['state'];
      cityController.text = addressMap['city'];
      countryController.text = addressMap['country'];
      pincodeController.text = addressMap['pincode'];
    }
  }

  TextEditingController line1Controller = TextEditingController();
  TextEditingController line2Controller = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var dialogWidth = MediaQuery.of(context).size.width * .8;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
          width: dialogWidth,
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .8),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Enter Address",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        FlatButton(
                          padding: EdgeInsets.all(5),
                          onPressed: fetchingLocation
                              ? null
                              : () async {
                                  if (fetchingLocation) return;

                                  setState(() {
                                    fetchingLocation = true;
                                  });
                                  LocationData loc = await getLocation();

                                  if (loc == null) {
                                    Toast.show(
                                        "Location needs to be allowed", context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.BOTTOM);
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      fetchingLocation = false;
                                    });
                                    return;
                                  }

                                  Address address = await Geocoder.local
                                      .findAddressesFromCoordinates(Coordinates(
                                          loc.latitude, loc.longitude))
                                      .then((value) => value.first);

                                  print(
                                      "location: ${address.toMap().toString()}");

                                  countryController.text = address.countryName;
                                  stateController.text = address.adminArea;
                                  cityController.text = address.subAdminArea;
                                  pincodeController.text = address.postalCode;
                                  line1Controller.text = address.addressLine
                                      .trim()
                                      .replaceAll(
                                          RegExp(
                                              '${address.countryName},*|${address.adminArea},*|${address.subAdminArea},*|${address.locality},*|${address.postalCode},*'),
                                          '')
                                      .trim()
                                      .replaceAll(
                                          RegExp(',\$', multiLine: true), '');
                                  line2Controller.text = address.locality;

                                  setState(() {
                                    fetchingLocation = false;
                                  });
                                },
                          child: Row(
                            children: [
                              Text(
                                'My Location',
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context).primaryColor),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                child: fetchingLocation
                                    ? Container(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Icon(Icons.location_searching_rounded,
                                        size: 20,
                                        color: Theme.of(context).primaryColor),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: TextFormField(
                              controller: line1Controller,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              },
                              decoration:
                                  InputDecoration(labelText: "Address Line 1"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: TextFormField(
                              controller: line2Controller,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              },
                              decoration:
                                  InputDecoration(labelText: "Address Line 2"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: TextFormField(
                              controller: stateController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              },
                              decoration: InputDecoration(labelText: "State"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: TextFormField(
                              controller: cityController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              },
                              decoration: InputDecoration(labelText: "City"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: TextFormField(
                              controller: countryController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              },
                              decoration: InputDecoration(labelText: "Country"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: TextFormField(
                              controller: pincodeController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              },
                              decoration:
                                  InputDecoration(labelText: "Pin Code"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RaisedButton(
                      padding: EdgeInsets.all(15),
                      // splashColor: Colors.lightBlue,
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Done",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          var locationMap = Map.fromEntries([
                            MapEntry('country', countryController.text),
                            MapEntry('state', stateController.text),
                            MapEntry('city', cityController.text),
                            MapEntry('pincode', pincodeController.text),
                            MapEntry('line1', line1Controller.text),
                            MapEntry('line2', line2Controller.text),
                          ]);

                          locationMap['addressLine'] =
                              "${locationMap['line1']}, ${locationMap['line2']}, ${locationMap['city']}, ${locationMap['state']}, ${locationMap['country']}, ${locationMap['pincode']}";

                          Navigator.of(context).pop(locationMap);
                        }
                      })
                ],
              ))),
    );
  }
}
