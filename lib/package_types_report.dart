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

class PackageTypesReport extends StatefulWidget {
  const PackageTypesReport({super.key});

  @override
  State<PackageTypesReport> createState() => _PackageTypesReport();
}

class _PackageTypesReport extends State<PackageTypesReport> {
  final firstDateController = TextEditingController();
  final lastDateController = TextEditingController();

  Widget result = SizedBox();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Package Types Report"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                  result = FutureBuilder(
                      future: Database.getPackageTypesCount(
                        dateFrom: firstDateController.text,
                        dateTo: lastDateController.text,
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
                            Map<String, double> freq = {
                              "Fragile": 0,
                              "Regular": 0,
                              "Chemical": 0,
                              "Liquid": 0,
                            };

                            List<DataRow> getRows() {
                              Iterable<ResultSetRow> packages = data;
                              List<DataRow> rows = [];

                              for (ResultSetRow r in packages) {
                                rows.add(
                                  DataRow(cells: [
                                    DataCell(Text(
                                      r.assoc()["Catagory"]!,
                                      style: kHeading2TextStyle,
                                    )),
                                    DataCell(
                                      Text(
                                        r.assoc()["Count"]!,
                                        style: kHeading2TextStyle,
                                      ),
                                    ),
                                  ]),
                                );

                                freq[r.assoc()["Catagory"]!] =
                                    double.parse(r.assoc()["Count"]!);
                              }
                              return rows;
                            }

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Number of Package Types",
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
                                              'Catagory',
                                              style: kHeading1TextStyle,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Count',
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
                                const Text(
                                  "Distribution of Categories",
                                  style: kHeading1TextStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: PieChart(
                                    dataMap: freq,
                                    colorList: [
                                      kPrimaryColor,
                                      kDarkColor,
                                      Colors.grey,
                                      Colors.grey.shade800,
                                    ],
                                  ),
                                ),
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
