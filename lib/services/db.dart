import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Db{

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(data, context) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef = users.doc(userID);
    await userDocRef
      .set(data)
      .then((value) => print("User Added"))
      .catchError((error){
        showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: Text("Sign up Failed"),
                content: Text(error.toString()),
              );
            }
        );
      });
  }

  Future<void> addProperty(data) async{
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef = users.doc(userID);
    CollectionReference additionalCollection = userDocRef.collection('properties');

    QuerySnapshot querySnapshot = await additionalCollection.get();
    int propertyCount = querySnapshot.docs.length;


    String newPropertyName = 'property${propertyCount + 1}';

    DocumentReference newPropertyRef = additionalCollection.doc(newPropertyName);

    CollectionReference monthlyCollection = newPropertyRef.collection('monthlyDetails');

    Map<String, dynamic> createMonthlyData() {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];

      Map<String, dynamic> monthlyData = {};

      for (String month in months) {
        monthlyData[month] = {
          'rent': "",
          'paid': false,
        };
      }

      return monthlyData;
    }

    Map<String, dynamic> monthlyData = createMonthlyData();

    Map<String, dynamic> newData = {
      ...data,
      'propertyId': newPropertyName,
    };

    await additionalCollection
        .doc(newPropertyName)
        .set(newData)
        .then((value) => print("Data Added to Additional Collection"))
        .catchError((error) {
              print("Failed");
      });

    monthlyData.forEach((month, data) {
      monthlyCollection.doc(month).set(data);
    });

  }

  Future<void> addApartment(data) async{
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef = users.doc(userID);
    CollectionReference additionalCollection = userDocRef.collection('apartments');

    QuerySnapshot querySnapshot = await additionalCollection.get();
    int propertyCount = querySnapshot.docs.length;


    String newPropertyName = 'apartment${propertyCount + 1}';

    Map<String, dynamic> newData = {
      ...data,
      'propertyId': newPropertyName,
    };

    await additionalCollection
        .doc(newPropertyName)
        .set(newData)
        .then((value) => print("Data Added to Additional Collection"))
        .catchError((error) {
      print("Failed");
    });
  }

  Future<void> addUnit(String apartmentId, Map<String, dynamic> data) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef = users.doc(userID);
    CollectionReference apartmentsCollection = userDocRef.collection('apartments');
    DocumentReference apartmentDocRef = apartmentsCollection.doc(apartmentId);


    DocumentSnapshot apartmentSnapshot = await apartmentDocRef.get();
    if (!apartmentSnapshot.exists) {
      print("Apartment with ID $apartmentId does not exist");
      return;
    }

    CollectionReference unitsCollection = apartmentDocRef.collection('units');

    QuerySnapshot querySnapshot = await unitsCollection.get();
    int unitCount = querySnapshot.docs.length;

    String newUnitId = 'unit${unitCount + 1}';

    DocumentReference newPropertyRef = unitsCollection.doc(newUnitId);

    CollectionReference monthlyCollection = newPropertyRef.collection('monthlyDetails');

    Map<String, dynamic> createMonthlyData() {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];

      Map<String, dynamic> monthlyData = {};

      for (String month in months) {
        monthlyData[month] = {
          'rent': "",
          'paid': false,
        };
      }

      return monthlyData;
    }

    Map<String, dynamic> monthlyData = createMonthlyData();


    Map<String, dynamic> newData = {
      ...data,
      'unitId': newUnitId,
    };

    await unitsCollection
        .doc(newUnitId)
        .set(newData)
        .then((value) => print("Data Added to Units Collection"))
        .catchError((error) {
      print("Failed to add unit: $error");
    });


    monthlyData.forEach((month, data) {
      monthlyCollection.doc(month).set(data);
    });

  }


  Future<void> editProperty(String propertyId, Map<String, dynamic> newData) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference propertyDocRef = users.doc(userID).collection('properties').doc(propertyId);

    await propertyDocRef
        .update(newData)
        .then((value) => print("Property Updated"))
        .catchError((error) {
      print("Failed to update property: $error");
    });
  }

  Future<void> editApartment(String apartmentId, Map<String, dynamic> newData) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference docRef = users.doc(userID).collection('apartments').doc(apartmentId);

    await docRef
        .update(newData)
        .then((value) => print("$apartmentId Updated"))
        .catchError((error) {
      print("Failed to update $apartmentId: $error");
    });
  }


  Future<Map<String, dynamic>> getUnitDetails(String apartmentId, String unitId) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef = users.doc(userID);
    CollectionReference apartmentsCollection = userDocRef.collection('apartments');
    DocumentReference apartmentDocRef = apartmentsCollection.doc(apartmentId);
    CollectionReference unitsCollection = apartmentDocRef.collection('units');
    DocumentReference unitDocRef = unitsCollection.doc(unitId);

    DocumentSnapshot unitSnapshot = await unitDocRef.get();

    if (unitSnapshot.exists) {
      return unitSnapshot.data() as Map<String, dynamic>;
    } else {
      // Handle the case when the unit doesn't exist
      return {};
    }
  }

  Future<void> editUnit(String apartmentId, String unitId, Map<String, dynamic> data) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef = users.doc(userID);
    CollectionReference apartmentsCollection = userDocRef.collection('apartments');
    DocumentReference apartmentDocRef = apartmentsCollection.doc(apartmentId);
    CollectionReference unitsCollection = apartmentDocRef.collection('units');
    DocumentReference unitDocRef = unitsCollection.doc(unitId);

    await unitDocRef
        .update(data)
        .then((value) => print("Unit Updated"))
        .catchError((error) {
      print("Failed to update unit: $error");
    });
  }

}