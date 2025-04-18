import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:propertypal/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import '../tabBar_contents/tabBar_display/house_tabBar.dart';



class HouseWidget extends StatelessWidget {
  HouseWidget({
    super.key,
    required this.userId,
  });

  final String? userId;

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

        return Houses(
          userId: userId,
        );
      },
    );
  }
}

class Houses extends StatelessWidget {
  const Houses({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _propertiesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('properties')
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: _propertiesStream,
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
            var property = snapshot.data!.docs[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeTabBar(propertyInfo: property),
                  ),
                );
                print("Container tapped: ${property['propertyName']}");
              },
              child: Container(
                width: double.infinity,
                height: 210,
                color: Colors.blue.shade200,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.black,
                            backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTiZbuK6fmV9HA2AlunPxND83z5MFvv3VccGQ&usqp=CAU"),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 8, right: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.home_filled, color: Colors.black54),
                                  SizedBox(width: 8),
                                  Text("${property['propertyName']}",
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
                                child: Text("${property['propertyAddress']}",
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Stack(
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
                                    'Home',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
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
                                                "${property['tenantName']}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
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
                                                "${property['startDate']} - ${property['endDate']}",
                                                style: TextStyle(
                                                    color: Colors.black26,
                                                    fontSize: 15),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Row(
                                            children: [
                                              Text("\$${property['tenantRent']}",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 15)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, top: 7),
                                          child: Row(
                                            children: [
                                              Text('Tenant Balance',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 15)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.black,
                                    backgroundImage: NetworkImage("https://www.livehome3d.com/assets/img/social/how-to-design-a-house.jpg"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
