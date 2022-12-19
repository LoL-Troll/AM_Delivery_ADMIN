import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mysql_client/src/mysql_client/connection.dart';
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

class PaymentsReport extends StatefulWidget {
  const PaymentsReport({super.key});

  @override
  State<PaymentsReport> createState() => _PaymentsReportState();
}

class _PaymentsReportState extends State<PaymentsReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Payments Report"),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FutureBuilder(
                  future: Database.getAllPackages(),
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
                            if (r.assoc()["Payment_Status"] == "1") {
                              double deliveryCost =
                                  double.parse(r.assoc()['Weight']!) * 0.5 +
                                      double.parse(r.assoc()['Length']!) * 0.3 +
                                      double.parse(r.assoc()['Width']!) * 0.3;

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
                                      "$deliveryCost SAR",
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
                                      r.assoc()["Expected_Delivery_Date"]!,
                                      style: kHeading2TextStyle,
                                    ),
                                  ),
                                ],
                              ));
                            }
                          }
                          return rows;
                        }

                        List<Widget> getItems() {
                          List<Widget> newitems = [];
                          for (ResultSetRow r in data) {
                            if (r.assoc()["Payment_Status"] == "1") {
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
                                "Summary of Paid Packages",
                                style: kHeading1TextStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  border: TableBorder.all(color: kDarkColor),
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
                                          'Amount',
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
                                          'Amount',
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
                              "Details Of Paid Packages",
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
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
