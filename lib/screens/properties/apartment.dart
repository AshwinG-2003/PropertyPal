import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../tabBar_contents/tabBar_display/unit_tabBar.dart';
import '../welcome_screen.dart';
import 'apartment_details.dart';

class ApartmentWidget extends StatelessWidget {
  ApartmentWidget({
    Key? key,
    required this.userId,
  });

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> _usersStream =
    FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    return StreamBuilder<DocumentSnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return Apartments(
          userId: userId,
        );
      },
    );
  }
}

class Apartments extends StatelessWidget {
  const Apartments({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _apartmentsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('apartments')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _apartmentsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return WelcomeScreen();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var apartment = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var apartmentId = snapshot.data!.docs[index].id;


            final Stream<QuerySnapshot> _unitsStream = FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('apartments')
                .doc(apartmentId) // Use the dynamic apartment ID
                .collection('units')
                .snapshots();

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ApartmentDetails(propertyInfo: apartment),
                  ),
                );
                print("Container tapped: ${apartment['propertyName']}");
              },

              child: Container(
                width: double.infinity,
                height: 100 + (112 * 1),
                color: Colors.green.shade200,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ApartmentDetails(propertyInfo: apartment),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.black,
                              backgroundImage: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTiZbuK6fmV9HA2AlunPxND83z5MFvv3VccGQ&usqp=CAU"),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 8, right: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.apartment, color: Colors.black54),
                                  SizedBox(width: 8),
                                  Text("${apartment['propertyName']}",
                                      style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text("${apartment['propertyAddress']}",
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _unitsStream,
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> unitSnapshot) {
                          if (unitSnapshot.hasError) {
                            return Text('Error fetching units');
                          }

                          if (!unitSnapshot.hasData || unitSnapshot.data!.docs.isEmpty) {
                            return Text('No Units Available');
                          }

                          return
                            ListView.builder(
                            itemCount: unitSnapshot.data!.docs.length,
                            itemBuilder: (context, unitIndex) {
                              var unit = unitSnapshot.data!.docs[unitIndex].data() as Map<String, dynamic>;
                              return GestureDetector(
                                onTap: () {
                                  print("Unit tapped: ${unit['unitId']}");
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => UnitTabBar(
                                        unitInfo: unit,
                                        userId: userId!,
                                        apartmentId: apartmentId,
                                        unitId: unit['unitId'],
                                      ),
                                    ),
                                  );
                                },
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 12, top: 35),
                                        child: Transform.rotate(
                                          angle: -90 * 3.1415926535 / 180,
                                          child: Container(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              "${unit['unitId']}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 356,
                                        height: 102,
                                        color: Colors.white,
                                        alignment: Alignment.topRight,
                                        padding: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "${unit['tenantName']}",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 8.0),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.key, color: Colors.grey),
                                                        Text(
                                                          "${unit['startDate']} - ${unit['endDate']}",
                                                          style: TextStyle(
                                                            color: Colors.black26,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "\$${unit['tenantRent']}",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 8.0, top: 7),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Tenant Balance',
                                                          style: TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const CircleAvatar(
                                              radius: 35,
                                              backgroundColor: Colors.black,
                                              backgroundImage: NetworkImage(
                                                "https://www.livehome3d.com/assets/img/social/how-to-design-a-house.jpg",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            );

          },
        );

      },
    );
  }
}