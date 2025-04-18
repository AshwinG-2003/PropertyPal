import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:propertypal/screens/settings/account_screen.dart';
import '../login_screens.dart';
import 'package:propertypal/screens/notification/notification.dart';



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key});

  @override
  State<SettingsScreen> createState() => _SettingsState();
}


class _SettingsState extends State<SettingsScreen> {
  var isLogoutLoading = false;
  bool receiveNotifications = true;

  Future<void> logOut() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildListTile("Account"),
          buildToggleListTileWithLabels(
            "Notifications",
            receiveNotifications,
                (bool value) {
              setState(() {
                receiveNotifications = value;
              });
            },
          ),
          buildListTileWithLogout("Log Out"),
        ],
      ),
    );
  }

  Widget buildListTile(String title) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(title),
          onTap: () {
            if (title == "Account") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountScreen()));
            } else if (title == "Log Out") {
              showLogoutConfirmationDialog(context);
            }
          },
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(
          color: Colors.grey.shade500,
          height: 0,
          thickness: 1,
        ),
      ],
    );
  }


  Widget buildListTileWithLogout(String title) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(title),
          onTap: () {
            if (title == "Log Out") {
              showLogoutConfirmationDialog(context);
            }
          },
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(
          color: Colors.grey.shade500,
          height: 0,
          thickness: 1,
        ),
      ],
    );
  }

  Widget buildToggleListTile(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildToggleListTileWithLabels(String title, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('OFF'),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
              Text('ON'),
            ],
          ),
        ),
        Divider(
          color: Colors.grey.shade400,
          height: 0,
          thickness: 1,
        ),
      ],
    );
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out of your account?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                logOut();
                Navigator.of(context).pop();
              },
              child: Text("Log Out"),
            ),
          ],
        );
      },
    );
  }
}
