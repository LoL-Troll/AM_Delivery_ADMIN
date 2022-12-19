import 'package:another_stepper/dto/stepper_data.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mysql_client/src/mysql_client/connection.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:test_db/EditCustomer.dart';
import 'package:test_db/EditProfile.dart';
import 'package:test_db/SendPackageUI.dart';
import 'package:test_db/constants.dart';
import 'package:test_db/customWidgets.dart';
import 'package:test_db/database.dart';
import 'package:test_db/track_package.dart';
import 'HistoryPackage.dart';
import 'PackageSummury.dart';
import 'package:test_db/ProfileMenu.dart';
import 'User.dart';

class PackageTrackingReport extends StatefulWidget {
  const PackageTrackingReport({super.key});

  @override
  State<PackageTrackingReport> createState() => _PackageTrackingReport();
}

class _PackageTrackingReport extends State<PackageTrackingReport> {
  final firstDateController = TextEditingController();
  final lastDateController = TextEditingController();

  Widget result = SizedBox();
  String? countryValue, stateValue, cityValue;
  late String category = "Regular";

  bool inTransit = false, delivered = false, lost = false, damaged = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Package Status Report"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
              child: Text(
                "Select Status to View:",
                style: kHeading1TextStyle,
              ),
            ),
            CheckboxListTile(
              title: const Text(
                'In Transit',
                style: kCaptionTextStyle,
              ),
              value: inTransit,
              onChanged: (bool? value) {
                setState(() {
                  inTransit = !inTransit;
                });
              },
              secondary: const Icon(Icons.local_shipping),
            ),
            CheckboxListTile(
              title: const Text(
                'Delivered',
                style: kCaptionTextStyle,
              ),
              value: delivered,
              onChanged: (bool? value) {
                setState(() {
                  delivered = !delivered;
                });
              },
              secondary: const Icon(Icons.check_circle),
            ),
            CheckboxListTile(
              title: const Text(
                'Lost',
                style: kCaptionTextStyle,
              ),
              value: lost,
              onChanged: (bool? value) {
                setState(() {
                  lost = !lost;
                });
              },
              secondary: const Icon(Icons.question_mark),
            ),
            CheckboxListTile(
              title: const Text(
                'Damaged',
                style: kCaptionTextStyle,
              ),
              value: damaged,
              onChanged: (bool? value) {
                setState(() {
                  damaged = !damaged;
                });
              },
              secondary: const Icon(Icons.broken_image),
            ),
            CustomDropdownButton(
                title: "Category",
                value: category,
                items: ["Regular", "Fragile", "Liquid", "Chemical"],
                onChanged: (String? value) {
                  setState(() {
                    category = value!;
                  });
                }),
            Padding(
              padding: EdgeInsets.all(15),
              child: CSCPicker(
                ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                dropdownDecoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),

                ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                disabledDropdownDecoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300)),

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
                    countryValue = value.substring(value.indexOf(" ")).trim();
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
            CustomBigButton(
              label: "Confirm",
              icon: Icons.table_chart,
              onPressed: () {
                setState(() {
                  List<String> statuses = [];
                  if (delivered) statuses.add("'Delivered'");
                  if (inTransit) statuses.add("'In Transit'");
                  if (lost) statuses.add("'Lost'");
                  if (damaged) statuses.add("'Damaged'");

                  result = FutureBuilder(
                      future: Database.getTrackingByStatusLocation(
                          city: cityValue!,
                          status: statuses,
                          category: category),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
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
                            var data = snapshot.data as Iterable<ResultSetRow>;

                            List<Widget> getItems() {
                              List<Widget> newitems = [];
                              for (ResultSetRow r in data) {
                                String packageID = r.assoc()["PackageID"]!;
                                String date =
                                    r.assoc()["Expected_Delivery_Date"]!;
                                String receiver = r.assoc()["ReceiverID"]!;
                                String sender = r.assoc()["SenderID"]!;
                                String status = r.assoc()["Status"]!;

                                newitems.add(
                                  CustomListViewItem(
                                    packageID: packageID,
                                    date: date,
                                    receiver: receiver,
                                    sender: sender,
                                    status: status,
                                  ),
                                );
                              }
                              return newitems;
                            }

                            print(getItems().length);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Divider(
                                    height: 10,
                                    indent: 30,
                                    endIndent: 30,
                                    color: kPrimaryColor,
                                    thickness: 2,
                                  ),
                                ),
                                Text(
                                  "Details Of Filtered Packages",
                                  style: kHeading1TextStyle,
                                ),
                                Column(
                                  children: getItems(),
                                )
                              ],
                            );
                          }
                        }
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
        ),
      ),
    );
  }
}
