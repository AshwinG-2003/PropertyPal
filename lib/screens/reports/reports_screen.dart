import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? selectedPropertyId;
  String? selectedApartmentId;
  String? totalPropertyIncomeDisplay = '0';
  String? totalApartmentIncomeDisplay = '0';
  List<String> propertyNames = [];
  List<String> propertyIds = [];
  List<String> apartmentNames = [];
  List<String> apartmentIds = [];

  @override
  void initState() {
    super.initState();
    retrieveUserProperties();
  }

  void retrieveUserProperties() {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        DocumentReference userRef = FirebaseFirestore.instance.collection(
            "users").doc(userId);

        userRef.get().then((DocumentSnapshot userSnapshot) {
          if (userSnapshot.exists) {
            CollectionReference propertiesCollection = userSnapshot.reference
                .collection('properties');

            propertiesCollection.get().then((QuerySnapshot propertiesSnapshot) {
              List<String> id = [];
              List<String> names = [];

              propertiesSnapshot.docs.forEach((
                  QueryDocumentSnapshot propertySnapshot) {
                String propertyid = propertySnapshot.id;

                var propertyName = propertySnapshot.get('propertyName');

                id.add(propertyid);
                names.add(propertyName);
              });

              setState(() {
                propertyIds = id;
                propertyNames =
                    names;
              });

              openPropertyDropdown();
            });
          } else {
            print("User document does not exist");
          }
        });
      } else {
        print("No user signed in");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void openPropertyDropdown() {
    if (propertyNames.isNotEmpty) {
      FocusScope.of(context).requestFocus(
          FocusNode());
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(0, 0, 0, 0),
        items: propertyIds.map((propertyid) {
          int index = propertyIds.indexOf(propertyid);
          String propertyName = propertyNames[index];
          return PopupMenuItem<String>(
            value: propertyid,
            child: Text('$propertyid - $propertyName'),
          );
        }).toList(),
      ).then((value) {
        setState(() {
          selectedPropertyId = value;
          fetchIncomeForProperty();
        });
      });
    } else {
      retrieveUserProperties();
    }
  }

  void fetchIncomeForProperty() {
    if (selectedPropertyId != null) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String userId = user.uid;

          DocumentReference propertyRef = FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection('properties')
              .doc(selectedPropertyId!);

          propertyRef.get().then((DocumentSnapshot propertySnapshot) {
            if (propertySnapshot.exists) {
              var propertyData = propertySnapshot.data() as Map<String,
                  dynamic>;
              var tenantRent = propertyData['tenantRent'];

              print('Tenant Rent: $tenantRent');

              setState(() {
                totalPropertyIncomeDisplay = tenantRent
                    .toString();
              });
            } else {
              print("Property document does not exist");
            }
          });
        } else {
          print("No user signed in");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void _retrieveUserApartments() {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        DocumentReference userRef = FirebaseFirestore.instance.collection(
            "users").doc(userId);

        userRef.get().then((DocumentSnapshot userSnapshot) {
          if (userSnapshot.exists) {
            CollectionReference apartmentsCollection = userSnapshot.reference
                .collection('apartments');

            apartmentsCollection.get().then((QuerySnapshot apartmentsSnapshot) {
              List<String> id = [];
              List<String> names = [];

              apartmentsSnapshot.docs.forEach((
                  QueryDocumentSnapshot apartmentSnapshot) {
                String apartmentId = apartmentSnapshot.id;

                var apartmentName = apartmentSnapshot.get('propertyName');

                id.add(apartmentId);
                names.add(apartmentName);
              });

              setState(() {
                apartmentIds = id;
                apartmentNames =
                    names;
              });

              _openApartmentDropdown();
            });
          } else {
            print("User document does not exist");
          }
        });
      } else {
        print("No user signed in");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _openApartmentDropdown() {
    if (apartmentNames.isNotEmpty) {
      FocusScope.of(context).requestFocus(
          FocusNode());
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(0, 0, 0, 0),
        items: apartmentIds.map((apartmentId) {
          int index = apartmentIds.indexOf(apartmentId);
          String apartmentName = apartmentNames[index];
          return PopupMenuItem<String>(
            value: apartmentId,
            child: Text(
                '$apartmentId - $apartmentName'),
          );
        }).toList(),
      ).then((value) {
        setState(() {
          selectedApartmentId = value;
          _fetchIncomeForApartment();
        });
      });
    } else {
      _retrieveUserApartments();
    }
  }

  void _fetchIncomeForApartment() {
    if (selectedApartmentId != null) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String userId = user.uid;

          CollectionReference unitsCollection = FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection('apartments')
              .doc(selectedApartmentId!)
              .collection('units');

          List<int> incomes = [];
          unitsCollection.get().then((QuerySnapshot unitsSnapshot) {
            unitsSnapshot.docs.forEach((QueryDocumentSnapshot unitSnapshot) {
              var unitData = unitSnapshot.data();
              if (unitData != null && unitData is Map<String, dynamic>) {
                if (unitData.containsKey('tenantRent')) {
                  String? rentString = unitData['tenantRent'];
                  int? rent = int.tryParse(rentString ?? '');
                  if (rent != null) {
                    setState(() {
                      incomes.add(rent);
                    });
                  }
                }
              }
            });

            int totalIncome = incomes.fold<int>(
                0, (prev, element) => prev + element);
            setState(() {
              totalApartmentIncomeDisplay =
                  totalIncome.toString();
            });
          });
        } else {
          print("No user signed in");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Widget _buildPropertyTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: openPropertyDropdown,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Select Property',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedPropertyId ?? 'Select Property'),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Income for Property",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("\$$totalPropertyIncomeDisplay"),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildApartmentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _openApartmentDropdown,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Select Apartment',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedApartmentId ?? 'Select Apartment'),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Income for Apartment",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("\$$totalApartmentIncomeDisplay"),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.black,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: Colors.black),
              ),
              tabs: [
                Tab(
                  child: Text(
                    "Properties",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    "Apartments",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPropertyTab(),
                  _buildApartmentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}