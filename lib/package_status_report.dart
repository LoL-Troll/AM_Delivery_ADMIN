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

class PackageStatusReport extends StatefulWidget {
  const PackageStatusReport({super.key});

  @override
  State<PackageStatusReport> createState() => _PackageTypesReport();
}

class _PackageTypesReport extends State<PackageStatusReport> {
  final firstDateController = TextEditingController();
  final lastDateController = TextEditingController();

  Widget result = SizedBox();

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
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
              child: Text(
                "Date Between:",
                style: kHeading1TextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
              child: TextField(
                  controller: firstDateController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.calendar_today),
                      labelText: "Enter Start Date"),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    setState(() {
                      firstDateController.text =
                          "${pickedDate!.year}-${pickedDate!.month}-${pickedDate!.day}";
                    });
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: TextField(
                  controller: lastDateController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.calendar_today),
                      labelText: "Enter End Date"),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    setState(() {
                      lastDateController.text =
                          "${pickedDate!.year}-${pickedDate!.month}-${pickedDate!.day}";
                    });
                  }),
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
                      future: Database.getPackagesBetweenDates(
                        dateFrom: firstDateController.text,
                        dateTo: lastDateController.text,
                        statuses: statuses,
                      ),
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

                            List<DataRow> getRows() {
                              Iterable<ResultSetRow> packages = data;
                              List<DataRow> rows = [];

                              for (ResultSetRow r in packages) {
                                rows.add(DataRow(
                                  cells: <DataCell>[
                                    DataCell(
                                      Text(
                                        r.assoc()["PackageID"]!,
                                        style: kHeading2TextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        r.assoc()["Status"]!,
                                        style: kHeading2TextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        r.assoc()["Sent_Date"]!,
                                        style: kHeading2TextStyle,
                                      ),
                                    ),
                                  ],
                                ));
                              }
                              return rows;
                            }

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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Summary Filtered Packages",
                                    style: kHeading1TextStyle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      border:
                                          TableBorder.all(color: kDarkColor),
                                      columns: const <DataColumn>[
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Package ID',
                                              style: kHeading1TextStyle,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Status',
                                              style: kHeading1TextStyle,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Sent Date',
                                              style: kHeading1TextStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: getRows(),
                                    ),
                                  ),
                                ),
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
