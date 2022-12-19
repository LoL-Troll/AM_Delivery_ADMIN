import 'dart:async';
import 'package:encrypt/encrypt.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:test_db/User.dart';

class Database {
  static late final MySQLConnection conn;
  static bool initialized = false;

  static Future<MySQLConnection> getConnection() async {
    // Open a connection (testdb should already exist)
    if (!initialized) {
      conn = await MySQLConnection.createConnection(
        host: '193.122.73.150',
        port: 3306,
        userName: "Troll",
        password: "Ics321#@!",
        databaseName: "sql7581270", // optional
      );

      initialized = true;
      await conn.connect();
      print("Connected");
    }
    return conn;
  }

  static Future<String?> addAdminUser({
    required String fName,
    required String lName,
    sex = null,
    required String phone,
    required String email,
    required String password,
  }) async {
    /// Encrypting the password
    final key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);

    await getConnection().then((conn) => conn.execute("""
    INSERT INTO USER
    VALUES(0, '$fName', '$lName', '$sex', '$phone', '$email', '${encrypted.base64}', 'Admin')"""));

    var id = (await getConnection().then((conn) => conn.execute("""
    SELECT UserID
    FROM USER
    WHERE email = '$email'"""))).rows.first.assoc()["UserID"];

    await getConnection().then((conn) => conn.execute("""
    INSERT INTO ADMIN
    VALUES($id)"""));

    print(
        "A USER (ADMIN) WITH NAME $fName $lName AND ID $id BEEN ADDED TO THE DATABASE");

    return id;
  }

  static Future<String?> addCustomerUser({
    required String fName,
    required String lName,
    sex = null,
    required String phone,
    required String email,
    required String password,
  }) async {
    /// Encrypting the password
    final key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);

    await getConnection().then((conn) => conn.execute("""
    INSERT INTO USER
    VALUES(0, '$fName', '$lName', '$sex', '$phone', '$email', '${encrypted.base64}', 'Customer')"""));

    var id = (await getConnection().then((conn) => conn.execute("""
    SELECT UserID
    FROM USER
    WHERE email = '$email'"""))).rows.first.assoc()["UserID"];

    await getConnection().then((conn) => conn.execute("""
    INSERT INTO CUSTOMER
    VALUES($id)"""));

    print(
        "A USER WITH NAME $fName $lName AND ID $id BEEN ADDED TO THE DATABASE");

    return id;
  }

  static Future<String?> addPackage({
    required int val,
    required int length,
    required int width,
    required int height,
    required int weight,
    required String catagory,
    required bool expressShipping,
    required String? reciverID,
  }) async {
    DateTime deliveryDate = DateTime.now().add(
      Duration(days: expressShipping ? 5 : 10),
    );
    String sendDateString =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

    String deliveryDateString =
        "${deliveryDate.year}-${deliveryDate.month}-${deliveryDate.day}";

    await getConnection().then(
      (conn) => conn.execute(
        """
        INSERT INTO PACKAGE
        VALUES(0, 'In Transit', '$deliveryDateString', $width, $length, $height,
        $weight, $val, '$catagory', ${User.getInstance().userId}, $reciverID, FALSE, '${sendDateString}')""",
      ),
    );

    var packageID = (await getConnection().then((conn) => conn.execute("""
    SELECT max(PackageID)
    FROM PACKAGE"""))).rows.first.assoc()["max(PackageID)"];
    return packageID;
  }

  static Future<String?> addHub({
    required String country,
    required String city,
    required String street,
    required String zip,
    required String type,
  }) async {
    await getConnection().then(
      (conn) => conn.execute(
        """
        INSERT INTO HUB
        VALUES(0, '$type', $zip, '$city', '$street', '$country')
        """,
      ),
    );

    var hubID = (await getConnection().then((conn) => conn.execute("""
    SELECT max(Hub_ID)
    FROM HUB"""))).rows.first.assoc()["max(Hub_ID)"];
    return hubID;
  }

  static Future<String?> editHub({
    required String country,
    required String city,
    required String street,
    required String zip,
    required String type,
    required String hubId,
  }) async {
    await getConnection().then(
      (conn) => conn.execute(
        """
        UPDATE HUB
         SET Country = '$country', City = '$city', Street = '$street', Zip_code = '$zip', Type = '$type'
         Where Hub_ID = $hubId;
        """,
      ),
    );
  }

  static Future<String?> addCustomerAddress({
    required String country,
    required String city,
    required String street,
    required String zip,
    required String houseNumber,
    required String customerID,
  }) async {
    String? hubID = await addHub(
        country: country,
        city: city,
        street: street,
        zip: zip,
        type: "Customer Address");

    await getConnection().then(
      (conn) => conn.execute(
        """
        INSERT INTO CUSTOMER_ADDRESS
        VALUES($hubID, $houseNumber, $customerID)
        """,
      ),
    );

    return hubID;
  }

  static void editCustomerInformation({
    required String id,
    required String fname,
    required String lname,
    required String sex,
    required String phone,
    required String email,
  }) async {
    await getConnection().then(
      (conn) => conn.execute(
        """
        UPDATE USER
        set Fname = '$fname', Lname = '$lname', Sex = '$sex', Phone = '$phone', Email = '$email'
        Where UserID = $id;
        """,
      ),
    );
  }

  static void editCustomerAddress({
    required String country,
    required String city,
    required String street,
    required String zip,
    required String hubId,
  }) async {
    await editHub(
      country: country,
      city: city,
      street: street,
      zip: zip,
      type: "Customer Address",
      hubId: hubId,
    );
  }

  static Future<Map<String, String?>> loginUser(
      {required String email, required String password}) async {
    /// Encrypting the password
    final key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);

    return (await getConnection().then((conn) => conn.execute("""
    SELECT *
    FROM USER JOIN ADMIN
    WHERE ADMIN.AdminID = USER.UserID
    AND email = '$email' AND password = '${encrypted.base64}'""")))
        .rows
        .first
        .assoc();
  }

  static Future<String?> getUserIDFromPhone({required String phone}) async {
    return (await getConnection().then((conn) => conn.execute("""
    SELECT UserID
    FROM USER
    WHERE Phone = $phone"""))).rows.first.assoc()["UserID"];
  }

  static Future<String?> getUserIDFromEmail({required String email}) async {
    return (await getConnection().then((conn) => conn.execute("""
    SELECT UserID
    FROM USER
    WHERE Email = '$email'"""))).rows.first.assoc()["UserID"];
  }

  static Future<Map<String, String?>> getCustomerInfoAndAddressFromEmailOrPhone(
      {required String input}) async {
    return (await getConnection().then((conn) => conn.execute("""
    SELECT *
    FROM USER, CUSTOMER_ADDRESS, HUB 
    WHERE USER.UserID = CUSTOMER_ADDRESS.CustomerID 
    AND CUSTOMER_ADDRESS.Hub_ID = HUB.Hub_ID
    AND (Email = '$input' OR Phone = '$input') AND USER.Type = 'Customer'""")))
        .rows
        .first
        .assoc();
  }

  static Future<Map<String, String?>> getUser({required String id}) async {
    var result = await getConnection().then((conn) => conn.execute("""
     SELECT *
     FROM USER
     WHERE UserID = $id;"""));

    return result.rows.first.assoc();
  }

  static Future<Iterable<ResultSetRow>> getAllPackages() async {
    var result = await getConnection().then((conn) => conn.execute("""
     SELECT *
     FROM PACKAGE
     """));

    return result.rows;
  }

  static Future<Iterable<ResultSetRow>> getPackagesBetweenDates({
    required String dateFrom,
    required String dateTo,
    required List<String> statuses,
  }) async {
    print(statuses.join(", "));
    var result = await getConnection().then(
      (conn) => conn.execute("""
     SELECT *
     FROM PACKAGE
     WHERE PACKAGE.Sent_Date BETWEEN "$dateFrom" AND "$dateTo"
     AND PACKAGE.Status in (${statuses.join(", ")})
     """),
    );

    return result.rows;
  }

  static Future<Iterable<ResultSetRow>> getPackageTypesCount({
    required String dateFrom,
    required String dateTo,
  }) async {
    var result = await getConnection().then((conn) => conn.execute("""
     SELECT Catagory, count(*) as Count
     FROM PACKAGE
     WHERE PACKAGE.Sent_Date BETWEEN "$dateFrom" AND "$dateTo"
     GROUP BY CATAGORY
     """));

    return result.rows;
  }

  static Future<Map<String, String?>> getPackage(
      {required String packageID}) async {
    var result = await getConnection().then((conn) => conn.execute("""
     SELECT *
     FROM PACKAGE
     WHERE PackageID = $packageID;"""));
    print("DB");
    print(result.rows.first.assoc());

    return result.rows.first.assoc();
  }

  static Future<String?> getReceiverIDByPackageID(
      {required String packageID}) async {
    var result = await getConnection().then((conn) => conn.execute("""
     SELECT *
     FROM PACKAGE
     WHERE PackageID = $packageID;"""));
    print("DB");
    print(result.rows.first.assoc());

    String customerId = result.rows.first.assoc()["ReceiverID"]!;

    var x = await getConnection().then((conn) => conn.execute("""
    Select *
    FROM CUSTOMER NATURAL JOIN CUSTOMER_ADDRESS NATURAL JOIN HUB
    Where CustomerID = $customerId;"""));


    return x.rows.first.assoc()["Hub_ID"];
  }

  static Future<Iterable<ResultSetRow>> getSentOrReceivedPackgesInTransit({
    required String? userID,
    bool sent = false,
    bool received = false,
  }) async {
    String condition = "";
    if (sent && received) {
      condition = "SenderID = $userID OR ReceiverID = $userID";
    } else if (sent) {
      condition = "SenderID = $userID";
    } else if (received) {
      condition = "ReceiverID = $userID";
    }

    var result = await getConnection().then((conn) => conn.execute("""
     SELECT *
     FROM PACKAGE p
     WHERE ($condition)
     AND p.Status = 'In Transit';"""));

    return result.rows;
  }

  static Future<Iterable<ResultSetRow>> getSentOrReceivedPackges({
    required String? userID,
    bool sent = false,
    bool received = false,
  }) async {
    String condition = "";
    if (sent && received) {
      condition = "SenderID = $userID OR ReceiverID = $userID";
    } else if (sent) {
      condition = "SenderID = $userID";
    } else if (received) {
      condition = "ReceiverID = $userID";
    }

    var result = await getConnection().then((conn) => conn.execute("""
     SELECT *
     FROM PACKAGE p
     WHERE ($condition)
     AND p.Status NOT IN ('In Transit');"""));

    return result.rows;
  }

  static Future<Iterable<ResultSetRow>> getTrackingDetails(
      {required String? packageID}) async {
    var result = await getConnection().then((conn) => conn.execute("""
    Select *
    FROM (PACKAGE p NATURAL JOIN TRANSPORTS t) NATURAL JOIN TRANSPORT_EVENT te NATURAL JOIN TRANSPORT_ACTIVITY ta
    WHERE p.PackageID = $packageID
    ORDER BY ScheduleNum asc ,Date asc, Activity desc"""));
    return result.rows;
  }

  static Future<Iterable<ResultSetRow>> getTrackingByStatusLocation(
      {required String city,
      required List<String?> status,
      required String category}) async {
    var result = await getConnection().then((conn) => conn.execute("""
    Select PackageID, max(ScheduleNum) as ScheduleNum, Status, Expected_Delivery_Date, SenderID, ReceiverID
    FROM (PACKAGE p NATURAL JOIN TRANSPORTS t) NATURAL JOIN TRANSPORT_EVENT te NATURAL JOIN TRANSPORT_ACTIVITY ta JOIN HUB h
    where DestinationHub = Hub_ID AND p.Status in (${status.join(", ")}) AND p.Catagory = '$category' AND h.City = '$city'
    GROUP BY PackageID"""));
    return result.rows;
  }

  static Future<Map<String, String?>> getHub({required String? HubID}) async {
    var result = await getConnection().then((conn) => conn.execute("""
    Select *
    FROM HUB
    Where Hub_ID = $HubID"""));
    return result.rows.first.assoc();
  }

  static Future<String> getCustomerEmail({required String? packageID}) async {
    var result = await getConnection().then((conn) => conn.execute("""
    Select ReceiverID
    FROM PACKAGE
    Where PackageID = $packageID"""));

    var user = await getUser(id: result.rows.first.assoc()["ReceiverID"]!);
    String email = user["Email"]!;

    return email;
  }

  static Future<Iterable<ResultSetRow>> getAllHubsWithType({
    required String type,
    required String city,
    required String country,
  }) async {
    var result = await getConnection().then((conn) => conn.execute("""
    SELECT *
    FROM HUB NATURAL JOIN ${type.toUpperCase().replaceAll(" ", "_")}
    WHERE HUB.City = '$city' AND HUB.Country = '$country';
    """));

    return result.rows;
  }

  static Future modifyCustomerUser(User user) async {
    String? id = user.userId,
        fName = user.FName,
        lName = user.LName,
        email = user.email,
        phone = user.phone,
        sex = user.sex;

    var x = await getConnection().then((conn) => conn.execute("""
    UPDATE USER
    SET FName = '$fName', LName = '$lName', sex = '$sex', email = '$email', Phone = '$phone'
    WHERE UserID = $id"""));
  }

  static Future modifyCustomerPassword(User user) async {
    String? password = user.password;
    String? id = user.userId;

    /// Encrypting the password
    final key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(password!, iv: iv);

    var x = await getConnection().then((conn) => conn.execute("""
    UPDATE USER
    SET Password = '${encrypted.base64}'
    WHERE UserID = $id"""));
    user.password = encrypted.base64;
  }

  static void addActivityInTransit({
    required String packageID,
    required String tranportType,
    required String destinationHubId,
  }) async {
    String? lastScheduleNum =
        (await getConnection().then((conn) => conn.execute(""" 
    SELECT max(ScheduleNum) as ScheduleNum
    FROM TRANSPORTS
    WHERE PackageID = $packageID;
    """))).rows.first.assoc()["ScheduleNum"];

    print(lastScheduleNum == null);

    print(lastScheduleNum.toString());

    String sourceHubID = lastScheduleNum == null // if there is no events
        ? (await getConnection().then((conn) => conn.execute(""" 
    SELECT Hub_ID 
    FROM CUSTOMER_ADDRESS
    WHERE CustomerID = (
      SELECT SenderID
      FROM PACKAGE
      WHERE PackageID = $packageID
    );
    """))).rows.first.assoc()["Hub_ID"]! // if exist events
        : (await getConnection().then((conn) => conn.execute(""" 
    SELECT DestinationHub 
    FROM TRANSPORT_EVENT
    WHERE ScheduleNum = $lastScheduleNum;
    """))).rows.first.assoc()["DestinationHub"]!;

    await getConnection().then((conn) => conn.execute("""
    INSERT INTO TRANSPORT_EVENT
    VALUES(0, '$tranportType', $sourceHubID, $destinationHubId);
    """));

    String newScheduleNum =
        (await getConnection().then((conn) => conn.execute("""
    SELECT max(ScheduleNum) as ScheduleNum
    FROM TRANSPORT_EVENT   
    """))).rows.first.assoc()["ScheduleNum"]!;

    await getConnection().then((conn) => conn.execute("""
    INSERT INTO TRANSPORTS
    VALUES($newScheduleNum, $packageID);
    """));

    await getConnection().then((conn) => conn.execute("""
    INSERT INTO TRANSPORT_ACTIVITY
    VALUES($newScheduleNum, 'In Transit', '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}');
    """));
  }

  static void setActivityArrived({required scheduleNum}) async {
    await getConnection().then((conn) => conn.execute("""
    INSERT INTO TRANSPORT_ACTIVITY
    VALUES('$scheduleNum', 'Arrived', '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}');
    """));

  }

  static Future<Map<String, String?>> getCustomerAddress(
      {required String customerId}) async {
    var x = await getConnection().then((conn) => conn.execute("""
    Select *
    FROM CUSTOMER NATURAL JOIN CUSTOMER_ADDRESS NATURAL JOIN HUB
    Where CustomerID = $customerId;"""));

    return x.rows.first.assoc();
  }

  static Future setPaidPackage({required String packageID}) async {
    var x = await getConnection().then((conn) => conn.execute("""
    UPDATE PACKAGE
    SET Payment_Status = 1
    WHERE PackageID = $packageID"""));
  }

  static Future setStatusPackage({required String packageID, required String status}) async {
    var x = await getConnection().then((conn) => conn.execute("""
    UPDATE PACKAGE
    SET Status = '$status'
    WHERE PackageID = $packageID"""));
  }

  static Future setPackageStatusDelivered({required String packageID}) async {
    var x = await getConnection().then((conn) => conn.execute("""
    UPDATE PACKAGE
    SET Status = 'Delivered'
    WHERE PackageID = $packageID"""));
    print("HELLO");
  }

  static Future deleteUser({required String id}) async {
    var x = await getConnection().then((conn) => conn.execute("""
    DELETE FROM USER
    WHERE USER.UserID = $id"""));
  }
}
