import 'package:flutter/material.dart';
import '../detailsTab/house_detailsTab.dart';
import '../balanceTab/house_balanceTab.dart';
import '../paymentTab/house_paymentsTab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeTabBar extends StatelessWidget {
  final Map<String, dynamic> propertyInfo;

  const HomeTabBar({Key? key, required this.propertyInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(propertyInfo['tenantName']),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.black,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: Colors.black),
              ),
              tabs: [
                Tab(text: 'Details'),
                Tab(text: 'Balance'),
                Tab(text: 'Payments'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  DetailsTab(property: propertyInfo),
                  BalanceTab(
                    propertyInfo: propertyInfo,
                    onMarkPaid: () => _markRentAsPaid(context),
                  ),
                  HousePaymentsTab(propertyInfo: propertyInfo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markRentAsPaid(BuildContext context) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final propertyId = propertyInfo['propertyId'];
    final tenantRent = propertyInfo['tenantRent'];

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('properties')
          .doc(propertyId)
          .collection('monthlyDetails')
          .doc(_getCurrentMonth())
          .update({'paid': true, 'rent': tenantRent});

    } catch (e) {
      print('Error updating rent status: $e');
    }
  }

  String _getCurrentMonth() {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);
    return currentMonth;
  }
}
