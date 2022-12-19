import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:test_db/DetailedTrack.dart';
import 'package:test_db/customWidgets.dart';
import 'package:test_db/database.dart';
import 'constants.dart';

class NewTransportEvent extends StatefulWidget {
  final String packageID;

  const NewTransportEvent({Key? key, required this.packageID});

  @override
  State<NewTransportEvent> createState() => _NewTransportEventState(
        packageID: packageID,
      );
}

class _NewTransportEventState extends State<NewTransportEvent> {
  String packageID;
  late String receiverHub;
  late String receiverEmail;
  late EmailContent email;

  _NewTransportEventState({required this.packageID});

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  getAllHubsWithType(
      {required String type,
      required String city,
      required String country}) async {
    var y = await Database.getReceiverIDByPackageID(packageID: packageID);
    receiverHub = y!;

    receiverEmail = await Database.getCustomerEmail(packageID: packageID);

    var x = await Database.getAllHubsWithType(
      type: selectedHubType!,
      city: cityValue!,
      country: countryValue,
    );

    return x;
  }

  List<String> hubs = [
    "Retail Center",
    "Warehouse",
    "Customer_Address",
    "Airport"
  ];
  String? selectedHubType;
  String? selectedHubName;
  String? selectedTranportType = "Truck";

  String countryValue = "";
  String? stateValue;
  String? cityValue;

  String value = "Warehouse";
  Widget result = SizedBox();
  List statusGroup = ['In Transit', 'Lost', 'Damaged'];
  String groupVal = "In Transit";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Event"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Select The State of the Package",
                style: kHeading1TextStyle,
              ),
              RadioListTile(
                title: Text("In Transit"),
                value: "In Transit",
                groupValue: groupVal,
                onChanged: (value) {
                  setState(() {
                    groupVal = value.toString();
                    print(groupVal);
                  });
                },
              ),
              RadioListTile(
                title: Text("Lost"),
                value: "Lost",
                groupValue: groupVal,
                onChanged: (value) {
                  setState(() {
                    groupVal = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text("Damaged"),
                value: "Damaged",
                groupValue: groupVal,
                onChanged: (value) {
                  setState(() {
                    groupVal = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text("Delayed"),
                value: "Delayed",
                groupValue: groupVal,
                onChanged: (value) {
                  setState(() {
                    groupVal = value.toString();
                  });
                },
              ),
              groupVal == "In Transit"
                  ? Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                          child: Text(
                            "Select The Destination Location",
                            style: kHeading1TextStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                          child: CSCPicker(
                            ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                            dropdownDecoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),

                            ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                            disabledDropdownDecoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey.shade300)),

                            ///placeholders for dropdown search field
                            countrySearchPlaceholder: "Country",
                            stateSearchPlaceholder: "State",
                            citySearchPlaceholder: "City",

                            ///labels for dropdown
                            countryDropdownLabel: "Country",
                            stateDropdownLabel: "State",
                            cityDropdownLabel: "City",

                            selectedItemStyle: kCaptionTextStyle,

                            ///DropdownDialog Heading style [OPTIONAL PARAMETER]
                            dropdownHeadingStyle: kHeading1TextStyle,

                            ///DropdownDialog Item style [OPTIONAL PARAMETER]
                            dropdownItemStyle: kCaptionTextStyle,

                            ///Dialog box radius [OPTIONAL PARAMETER]
                            dropdownDialogRadius: 10.0,

                            ///Search bar radius [OPTIONAL PARAMETER]
                            searchBarRadius: 10.0,

                            ///triggers once country selected in dropdown
                            onCountryChanged: (value) {
                              setState(() {
                                ///store value in country variable
                                countryValue =
                                    value.substring(value.indexOf(" ")).trim();
                              });
                            },

                            ///triggers once state selected in dropdown
                            onStateChanged: (value) {
                              setState(() {
                                ///store value in state variable
                                stateValue = value;
                              });
                            },

                            ///triggers once city selected in dropdown
                            onCityChanged: (value) {
                              setState(() {
                                ///store value in city variable
                                cityValue = value;
                              });
                            },
                          ),
                        ),
                        CustomDropdownButton(
                          title: "Destination Hub Type",
                          value: value,
                          items: hubs,
                          onChanged: (String? value) {
                            setState(() {
                              selectedHubType = value;
                              result = FutureBuilder(
                                  future: getAllHubsWithType(
                                    type: selectedHubType!,
                                    city: cityValue!,
                                    country: countryValue,
                                  ),
                                  builder: (ctx, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      // If we got an error
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text(
                                            '${snapshot.error} occurred',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        );

                                        // if we got our data
                                      } else if (snapshot.hasData) {
                                        // Extracting data from snapshot object
                                        var data = snapshot.data
                                            as Iterable<ResultSetRow>;
                                        Map<String, int> hubNamesAndID = {};
                                        if (data.first.assoc()["Type"] ==
                                            "Customer Address") {
                                          // hubNamesAndID.addAll(receiverHub);
                                          return Column(
                                            children: [
                                              CustomDropdownButton(
                                                title: "Customer Hub Number",
                                                items: [receiverHub],
                                                value: receiverHub,
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    selectedHubName = value;
                                                  });
                                                },
                                              ),
                                              CustomDropdownButton(
                                                  title: "Transport Type",
                                                  value: "Truck",
                                                  items: ["Truck"],
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedTranportType =
                                                          value;
                                                    });
                                                  }),
                                              CustomBigButton(
                                                  label: "Confirm",
                                                  onPressed: () {
                                                    Database.addActivityInTransit(
                                                        packageID: packageID,
                                                        tranportType:
                                                            selectedTranportType!,
                                                        destinationHubId:
                                                            "$selectedHubName");
                                                    setState(() {
                                                      Navigator.pop(context);
                                                    });
                                                  })
                                            ],
                                          );
                                        } else {
                                          for (ResultSetRow r in data) {
                                            hubNamesAndID[r.assoc()["Name"]!] =
                                                int.parse(r.assoc()["Hub_ID"]!);
                                          }
                                          return Column(
                                            children: [
                                              CustomDropdownButton(
                                                title: "Destination Hub Name",
                                                items:
                                                    hubNamesAndID.keys.toList(),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    selectedHubName = value;
                                                  });
                                                },
                                              ),
                                              CustomDropdownButton(
                                                  title: "Transport Type",
                                                  value: "Truck",
                                                  items: ["Truck", "Plane"],
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedTranportType =
                                                          value;
                                                    });
                                                  }),
                                              CustomBigButton(
                                                  label: "Confirm",
                                                  onPressed: () {
                                                    Database.addActivityInTransit(
                                                        packageID: packageID,
                                                        tranportType:
                                                            selectedTranportType!,
                                                        destinationHubId:
                                                            "${hubNamesAndID[selectedHubName]}");
                                                    Alert(
                                                        context: context,
                                                        title:
                                                            "Do you want to send an Email ?",
                                                        buttons: [
                                                          DialogButton(
                                                            child: Text(
                                                              "YES",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              EmailContent
                                                                  email =
                                                                  EmailContent(
                                                                to: [
                                                                  receiverEmail,
                                                                ],
                                                                subject:
                                                                    'Shipping Status Updated!',
                                                                body:
                                                                    'Your Package ID $packageID Has been Updated',
                                                              );

                                                              OpenMailAppResult
                                                                  result =
                                                                  await OpenMailApp.composeNewEmailInMailApp(
                                                                      nativePickerTitle:
                                                                          'Select email app to compose',
                                                                      emailContent:
                                                                          email);
                                                              if (!result
                                                                      .didOpen &&
                                                                  !result
                                                                      .canOpen) {
                                                                showNoMailAppsDialog(
                                                                    context);
                                                              } else if (!result
                                                                      .didOpen &&
                                                                  result
                                                                      .canOpen) {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) =>
                                                                      MailAppPickerDialog(
                                                                    mailApps: result
                                                                        .options,
                                                                    emailContent:
                                                                        email,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            width: 120,
                                                          ),
                                                          DialogButton(
                                                            child: Text(
                                                              "NO",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20),
                                                            ),
                                                            onPressed: () =>
                                                                Navigator
                                                                    .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DetailedTrack(
                                                                        packageID:
                                                                            packageID),
                                                              ),
                                                              (route) => false,
                                                            ),
                                                            width: 120,
                                                          ),
                                                        ],
                                                        style: AlertStyle(
                                                          titleStyle:
                                                              kHeading1TextStyle,
                                                        )).show();
                                                  })
                                            ],
                                          );
                                        }
                                      }
                                    }
                                    print(groupVal);
                                    // Displaying LoadingSpinner to indicate waiting state
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  });
                            });
                          },
                        ),
                        result,
                      ],
                    )
                  : CustomBigButton(
                      label: "Confirm",
                      onPressed: () {
                        Database.setStatusPackage(
                            packageID: packageID, status: groupVal);
                        Alert(
                            context: context,
                            title:
                            "Do you want to send an Email ?",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "YES",
                                  style: TextStyle(
                                      color: Colors
                                          .white,
                                      fontSize: 20),
                                ),
                                onPressed:
                                    () async {
                                  EmailContent
                                  email =
                                  EmailContent(
                                    to: [
                                      receiverEmail,
                                    ],
                                    subject:
                                    'Shipping Status Updated!',
                                    body:
                                    'Your Package ID $packageID Has been Updated',
                                  );

                                  OpenMailAppResult
                                  result =
                                  await OpenMailApp.composeNewEmailInMailApp(
                                      nativePickerTitle:
                                      'Select email app to compose',
                                      emailContent:
                                      email);
                                  if (!result
                                      .didOpen &&
                                      !result
                                          .canOpen) {
                                    showNoMailAppsDialog(
                                        context);
                                  } else if (!result
                                      .didOpen &&
                                      result
                                          .canOpen) {
                                    showDialog(
                                      context:
                                      context,
                                      builder: (_) =>
                                          MailAppPickerDialog(
                                            mailApps: result
                                                .options,
                                            emailContent:
                                            email,
                                          ),
                                    );
                                  }
                                },
                                width: 120,
                              ),
                              DialogButton(
                                child: Text(
                                  "NO",
                                  style: TextStyle(
                                      color: Colors
                                          .white,
                                      fontSize: 20),
                                ),
                                onPressed: () =>
                                    Navigator.of(context)
                                        .popUntil(ModalRoute.withName("/NewTransportEvent"))
                                ,
                                width: 120,
                              ),
                            ],
                            style: AlertStyle(
                              titleStyle:
                              kHeading1TextStyle,
                            )).show();
                      }),
            ],
          ),
        ),
      ),
    );
  }
}
