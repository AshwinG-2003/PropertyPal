import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceTab extends StatefulWidget {
  final Map<String, dynamic> propertyInfo;
  final VoidCallback onMarkPaid;

  const BalanceTab({
    Key? key,
    required this.propertyInfo,
    required this.onMarkPaid,
  }) : super(key: key);

  @override
  _BalanceTabState createState() => _BalanceTabState();
}

class _BalanceTabState extends State<BalanceTab> {
  bool rentPaid = false;
  double rentAmountValue = 0.0;

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
                        _getCurrentMonth(),
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
                    color: Colors.blue.shade200,
                    border: Border(
                      top: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        "Tenant Monthly Rent: \$${widget.propertyInfo['tenantRent']}",
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
                        "Status:",
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
                        '${rentPaid ? 'Paid' : 'Not Paid'}',
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
                        "Amount Paid:",
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

          ElevatedButton(
            onPressed: () {
              widget.onMarkPaid();
              _getBalanceText(widget.propertyInfo['propertyId'], _getCurrentMonth());
            },
            child: Text('Mark Rent Paid In Full'),
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
        final bool isRentPaid = snapshot.data()?['paid'] ?? false;
        final double rentAmount = double.parse(snapshot.data()?['rent'] ?? '0.0');

        setState(() {
          rentPaid = isRentPaid;
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
