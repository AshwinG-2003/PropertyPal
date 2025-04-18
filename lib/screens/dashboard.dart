import 'package:flutter/material.dart';
import 'package:propertypal/screens/home_screen.dart';
import 'package:propertypal/screens/settings/settings_screen.dart';
import 'package:propertypal/screens/reminder_screen.dart';
import 'package:propertypal/widgets/navbar.dart';
import 'package:propertypal/screens/reports/reports_screen.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var isLogoutLoading = false;
  int currentIndex = 0;
  var pageViewList = [HomeScreen(), ReminderScreen(), ReportScreen(), SettingsScreen()];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
      body: pageViewList[currentIndex],
    );
  }
}