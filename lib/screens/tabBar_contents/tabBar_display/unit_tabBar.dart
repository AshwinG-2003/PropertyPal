import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../balanceTab/unit_balanceTab.dart';
import '../paymentTab/unit_paymentTab.dart';
import '../detailsTab/unitdetails.dart';


class UnitTabBar extends StatelessWidget {

  final Map<dynamic, dynamic> unitInfo;
  final String userId;
  final String apartmentId;
  final unitId;

  const UnitTabBar(
      {
        Key? key,
        required this.userId,
        required this.apartmentId,
        required this.unitId,
        required this.unitInfo,
      }
  ) : super(key: key);


  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: Text(unitInfo['unitName'] ?? 'Property Name Not Available'),),
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
                  UnitDetailsPage(userId: userId, apartmentId: apartmentId, unitId: unitId),
                  BalanceTabApartment(apartmentId: apartmentId, unitInfo: unitInfo, onMarkPaid: () => _markRentAsPaid(context)),
                  UnitPaymentsTab(apartmentId: apartmentId, unitInfo: unitInfo),
                  // HousePaymentsTab(propertyInfo: unitInfo: unitInfo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _markRentAsPaid(BuildContext context) async {
    try {
      final unitRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('apartments')
          .doc(apartmentId)
          .collection('units')
          .doc(unitId);

      final unitDoc = await unitRef.get();
      final currentTenantRent = unitDoc.get('tenantRent');
      await unitRef
          .collection('monthlyDetails')
          .doc(_getCurrentMonth())
          .update({'paid': true, 'rent': currentTenantRent});
    } catch (e) {
      final unitRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('apartments')
          .doc(apartmentId)
          .collection('units')
          .doc(unitId);
      final unitDoc = await unitRef.get();
      final currentTenantRent = unitDoc.get('tenantRent');
      print('Error marking rent as paid: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking rent as paid. Please try again.' ),
        ),
      );
    }
  }
  String _getCurrentMonth() {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);
    return currentMonth;
  }

}
