import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HousePaymentsTab extends StatefulWidget {
  final Map<String, dynamic> propertyInfo;

  const HousePaymentsTab({
    Key? key,
    required this.propertyInfo,
  }) : super(key: key);

  @override
  _PaymentsTabState createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<HousePaymentsTab> {
  bool rentPaid = false;
  int rentAmountValue = 0;

  @override
  void initState() {
    super.initState();
    _getBalanceText(widget.propertyInfo['propertyId'], _getCurrentMonth());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Row(
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
                        _getCurrentYear(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),

                    ),
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        "${widget.propertyInfo['tenantName']}",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        '\$${rentAmountValue}',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentMonth() {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);
    return currentMonth;
  }

  String _getCurrentYear() {
    DateTime now = DateTime.now();
    String currentYear = DateFormat('MMMM yyyy').format(now);
    return currentYear;
  }


  Future<void> _getBalanceText(String propertyId, String documentField) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('properties')
          .doc(propertyId)
          .collection('monthlyDetails')
          .doc(_getCurrentMonth())
          .get();

      if (snapshot.exists) {
        final int rentAmount = int.parse(snapshot.data()?['rent'] ?? '0');

        setState(() {
          rentAmountValue = rentAmount;
        });
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error getting rent details: $error');
    }
  }

}

