import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
class ReminderScreen extends StatefulWidget {
  ReminderScreen({Key? key});
  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late List<String> propertyNames;
  late List<String> propertyIds;
  late List<String> apartmentIds;
  late List<String> unitIds;
  late List<String> combinedIds;
  late List<bool> isCheckedList;
  late String selectedMonth;
  Map<String, bool> isMonthExpanded = {};
  List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  void initState() {
    super.initState();
    propertyNames = [];
    propertyIds = [];
    apartmentIds = [];
    combinedIds = [];
    unitIds = [];
    isCheckedList = [];
    _initializeLists();
  }

  void navigateToRemindersDetails() {}
  final userID = FirebaseAuth.instance.currentUser!.uid;

  void _initializeLists() async {
    PropertyData propertyData = await _fetchPropertiesAndApartments();
    propertyNames = propertyData.propertyNames;
    propertyIds = propertyData.propertyIds;
    apartmentIds = propertyData.apartmentIds;
    unitIds = propertyData.unitIds;
    combinedIds.addAll(propertyData.propertyIds);
    combinedIds.addAll(propertyData.apartmentIds);
    int lengthDifference = combinedIds.length - unitIds.length;
    if (lengthDifference > 0) {
      unitIds.insertAll(0, List.filled(lengthDifference, ''));
    }

    isCheckedList = List.generate(combinedIds.length, (index) => false);

    String currentMonth = _getCurrentMonth();
    for (int i = 0; i < combinedIds.length; i++) {
      bool isPaid = await _fetchPaymentStatus(combinedIds[i], unitIds[i], currentMonth);
      isCheckedList[i] = isPaid;
    }


    setState(() {
      propertyNames = propertyNames;
      propertyIds = propertyIds;
      apartmentIds = apartmentIds;
      unitIds = unitIds;
      combinedIds = combinedIds;
      isCheckedList = isCheckedList;
      for (String month in months) { isMonthExpanded[month] = false;}

    });
  }

  Future<bool> _fetchPaymentStatus(String combinedIds, String unitId, String month) async {
    try {
      DocumentSnapshot snapshot;
      if (combinedIds.contains("property")) {
        var documentReference = FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('properties')
            .doc(combinedIds)
            .collection('monthlyDetails')
            .doc(month);

        snapshot = await documentReference.get();
      } else {
        var documentReference = FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('apartments')
            .doc(combinedIds)
            .collection('units')
            .doc(unitId)
            .collection('monthlyDetails')
            .doc(month);

        snapshot = await documentReference.get();
      }

      return snapshot.exists ? (snapshot.data() != null && (snapshot.data() as Map<String, dynamic>)['paid'] == true) : false;
    } catch (e) {
      print('Error fetching payment status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminders", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.black,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: Colors.black),
              ),
              tabs: [
                Tab(
                  child: Text(
                    "Unpaid",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    "Paid",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPropertyTab(),
                  _buildStatusTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return GestureDetector(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    propertyNames[index],
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Checkbox(
            value: isCheckedList[index],
            onChanged: (bool? value) {
              setState(() {
                isCheckedList[index] = value ?? false;
              });
              update(combinedIds[index], unitIds[index], isCheckedList[index]);
              print("property Names: $propertyNames");
              print("property Ids: $propertyIds");
              print("apartment Ids: $apartmentIds");
              print("combinedIds Ids: $combinedIds");
              print("unitIds Ids: $unitIds");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int index = 0; index < propertyNames.length; index++)
            if (!isCheckedList[index])
              _buildListItem(index),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int index = 0; index < propertyNames.length; index++)
            if (isCheckedList[index])
              _buildListItem(index),
        ],
      ),
    );
  }


  String _getCurrentMonth() {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);
    return currentMonth;
  }

  Future<void> update(String combinedIds, String unitId, bool value) async {
    String documentField = _getCurrentMonth();
    String tenantRent = '';
    try {
      if (combinedIds.contains("property")) {
        var documentReference = FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('properties')
            .doc(combinedIds);

        var snapshot = await documentReference.get();
        if (snapshot.exists) {
          if (snapshot.data()?['tenantRent'] != null) {
            tenantRent = snapshot.data()?['tenantRent'];
            print('Tenant Rent: $tenantRent');
          } else {
            print('Tenant Rent does not exist in the document.');
          }
        }
        tenantRent = value ? tenantRent : '';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('properties')
            .doc(combinedIds)
            .collection('monthlyDetails')
            .doc(documentField)
            .update({'paid': value, 'rent': tenantRent});
      }

      else {
        var documentReference = FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('apartments')
            .doc(combinedIds)
            .collection("units")
            .doc(unitId);

        var snapshot = await documentReference.get();
        if (snapshot.exists) {
          if (snapshot.data()?['tenantRent'] != null) {
            tenantRent = snapshot.data()?['tenantRent'];
            print('Tenant Rent: $tenantRent');
          } else {
            print('Tenant Rent does not exist in the document.');
          }
        }
        tenantRent = value ? tenantRent : '';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('apartments')
            .doc(combinedIds)
            .collection('units')
            .doc(unitId)
            .collection('monthlyDetails')
            .doc(documentField)
            .update({'paid': value, 'rent': tenantRent});
      }
    } catch (e) {
      print('Error updating Firebase: $e');
    }
    print('PropertyId: $combinedIds, isChecked: $value');
  }

}

Future<PropertyData> _fetchPropertiesAndApartments() async {
  final userID = FirebaseAuth.instance.currentUser!.uid;

  try {
    QuerySnapshot propertiesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('properties')
        .get();

    QuerySnapshot apartmentsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('apartments')
        .get();

    List<String> propertyNames = [];
    List<String> propertyIds = [];
    List<String> unitIds = [];
    List<String> apartmentIds = [];

    List<String> propertyNamesFromProperties =
    propertiesSnapshot.docs.map((doc) => doc['propertyName'] as String).toList();
    propertyNames.addAll(propertyNamesFromProperties);

    List<String> propertyIDFromProperties =
    propertiesSnapshot.docs.map((doc) => doc['propertyId'] as String).toList();
    propertyIds.addAll(propertyIDFromProperties);

    for (QueryDocumentSnapshot apartmentDoc in apartmentsSnapshot.docs) {
      QuerySnapshot unitsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('apartments')
          .doc(apartmentDoc.id)
          .collection('units')
          .get();

      List<String> propertyNamesFromApartments =
      unitsSnapshot.docs.map((doc) => doc['unitName'] as String).toList();
      propertyNames.addAll(propertyNamesFromApartments);

      List<String> propertyIDFromApartments =
      unitsSnapshot.docs.map((doc) => doc['unitId'] as String).toList();
      unitIds.addAll(propertyIDFromApartments);

      apartmentIds.addAll(List.generate(propertyIDFromApartments.length, (index) => apartmentDoc.id));
    }

    return PropertyData(
      propertyNames: propertyNames,
      propertyIds: propertyIds,
      unitIds: unitIds,
      apartmentIds: apartmentIds,
    );
  } catch (e) {
    print('Error fetching data: $e');
    return PropertyData(
      propertyNames: [],
      propertyIds: [],
      unitIds: [],
      apartmentIds: [],
    );
  }
}

class PropertyData {
  List<String> propertyNames;
  List<String> propertyIds;
  List<String> unitIds;
  List<String> apartmentIds;
  PropertyData({
    required this.propertyNames,
    required this.propertyIds,
    required this.unitIds,
    required this.apartmentIds,
  });
}

