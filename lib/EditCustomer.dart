import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:test_db/EditAddress.dart';
import 'package:test_db/EditPassword.dart';
import 'package:test_db/User.dart';
import 'package:test_db/database.dart';
import 'package:test_db/main.dart';
import 'constants.dart';
import 'customWidgets.dart';

class EditCustomer extends StatefulWidget {
  const EditCustomer({Key? key}) : super(key: key);

  @override
  State<EditCustomer> createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  final userController = TextEditingController();
  Widget result = SizedBox();

  Future<Map<String, String?>> getCustomerInformation(String input) async {
    var x =
        await Database.getCustomerInfoAndAddressFromEmailOrPhone(input: input);
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Customer Information"),
        centerTitle: true,
      ),
      // backgroundColor: kLightColor,
      body: SingleChildScrollView(
          child: Column(
        children: [
          CustomInputTextField(
            label: "Enter Customer Email or Phone Number",
            controller: userController,
          ),
          CustomBigButton(
              label: "Get Customer",
              icon: Icons.search,
              onPressed: () {
                setState(() {
                  result = FutureBuilder(
                    future: getCustomerInformation(userController.text),
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
                          Map<String, String?> data =
                              snapshot.data as Map<String, String?>;

                          final fNameController =
                              TextEditingController(text: data["Fname"]);
                          final lNameController =
                              TextEditingController(text: data["Lname"]);
                          final emailController =
                              TextEditingController(text: data["Email"]);
                          final phoneController =
                              TextEditingController(text: data["Phone"]);
                          final zipCodeController =
                              TextEditingController(text: data["Zip_code"]);
                          final streetController =
                              TextEditingController(text: data["Street"]);
                          final houseNumberController =
                              TextEditingController(text: data["HouseNumber"]);

                          late String fName,
                              lName,
                              gender = data["Sex"]! == "M" ? "Male" : "Female",
                              email,
                              phone;
                          String? countryValue, stateValue, cityValue;

                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomInputTextField(
                                  label: "First Name",
                                  controller: fNameController,
                                  inputformatters: [
                                    LengthLimitingTextInputFormatter(20)
                                  ],
                                ),
                                CustomInputTextField(
                                  label: "Last Name",
                                  controller: lNameController,
                                  inputformatters: [
                                    LengthLimitingTextInputFormatter(20)
                                  ],
                                ), // First Name, Last Name
                                CustomDropdownButton(
                                    title: "Gender",
                                    value: gender,
                                    items: ["Male", "Female"],
                                    onChanged: (String? value) {
                                      setState(() {
                                        gender = value!;
                                      });
                                    }),

                                CustomInputTextField(
                                  label: "Email",
                                  controller: emailController,
                                  inputformatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                ), // Email
                                CustomInputTextField(
                                  label: "Phone Number",
                                  controller: phoneController,
                                  keyboardtype: TextInputType.phone,
                                  inputformatters: [
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    "Region Information",
                                    style: kCaptionTextStyle,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: CSCPicker(
                                    ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                                    dropdownDecoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                    ),

                                    ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                                    disabledDropdownDecoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300)),

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
                                        countryValue = value
                                            .substring(value.indexOf(" "))
                                            .trim();

                                        print("HEEHEHEE  " +
                                            countryValue! +
                                            "  HEEHE");
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
                                CustomInputTextField(
                                  label: "Zip Code",
                                  controller: zipCodeController,
                                  keyboardtype: TextInputType.number,
                                ),
                                CustomInputTextField(
                                  label: "Street",
                                  controller: streetController,
                                  inputformatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                ),
                                CustomInputTextField(
                                  label: "House Number",
                                  controller: houseNumberController,
                                  keyboardtype: TextInputType.number,
                                ),
                                CustomBigButton(
                                  label: "Confirm Changes",
                                  onPressed: () {
                                    if (fNameController.text.isNotEmpty &&
                                        lNameController.text.isNotEmpty &&
                                        emailController.text.isNotEmpty &&
                                        phoneController.text.isNotEmpty &&
                                        countryValue != null &&
                                        cityValue != null &&
                                        streetController.text.isNotEmpty &&
                                        zipCodeController.text.isNotEmpty &&
                                        houseNumberController.text.isNotEmpty) {
                                      Database.editCustomerInformation(
                                          id: data["UserID"]!,
                                          fname: fNameController.text,
                                          lname: lNameController.text,
                                          sex: gender == "Male" ? "M" : "F",
                                          phone: phoneController.text,
                                          email: emailController.text);
                                      Database.editCustomerAddress(
                                          country: countryValue!,
                                          city: cityValue!,
                                          street: streetController.text,
                                          zip: zipCodeController.text,
                                          hubId: data["Hub_ID"]!);

                                      Navigator.pop(context);
                                    } else {
                                      Alert(
                                          context: context,
                                          title: "All Fields Must Be Filled",
                                          buttons: [
                                            DialogButton(
                                              child: Text(
                                                "OK",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              width: 120,
                                            )
                                          ],
                                          style: AlertStyle(
                                            titleStyle: kHeading1TextStyle,
                                          )).show();
                                    }
                                  },
                                ),
                                CustomBigButton(
                                    label: "Delete User",
                                    icon: Icons.delete,
                                    onPressed: () {
                                      print("IOWJFOIJAWOPIFJA");
                                      Alert(
                                          context: context,
                                          title:
                                              "Are You Sure You Want To Delete This User?",
                                          buttons: [
                                            DialogButton(
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              onPressed: () {
                                                Database.deleteUser(
                                                    id: data["UserID"]!);
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              width: 120,
                                            )
                                          ],
                                          style: AlertStyle(
                                            titleStyle: kHeading1TextStyle,
                                          )).show();
                                      print("WHHAT");
                                    }),
                              ],
                            ),
                          );
                        }
                      }

                      // Displaying LoadingSpinner to indicate waiting state
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                });
              }),
          result,
        ],
      )),
    );
  }
}
