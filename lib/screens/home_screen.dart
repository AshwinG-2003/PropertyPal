import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertypal/screens/properties/apartment.dart';
import 'package:propertypal/screens/properties/house.dart';
import 'package:propertypal/widgets/add_apartment_form.dart';
import '../widgets/add_property_form.dart';
import 'login_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isLogoutLoading = false;
  logOut() async {
    setState(() {
      isLogoutLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );

    setState(() {
      isLogoutLoading = false;
    });
  }

  final userID = FirebaseAuth.instance.currentUser!.uid;

  void showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Property"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddPropertyForm(),
                      ),
                    );
                  },
                  child: Text("Add House"),
                ),
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddApartmentForm(),
                      ),
                    );
                  },
                  child: Text("Add Apartment"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Properties",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showAddOptionsDialog();
            },
            icon: isLogoutLoading
                ? CircularProgressIndicator()
                : Icon(
              Icons.add_circle_outline,
            ),
          )
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(text: 'Houses'),
                Tab(text: 'Apartments'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  HouseWidget(userId: userID),
                  ApartmentWidget(userId: userID),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



