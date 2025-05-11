import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MindBridge/dev_phase.dart';
import 'package:MindBridge/doctor/doctor_list_page.dart';


import '../BookingDetailsPage.dart';
import '../ProfilePage.dart';
import 'Logout Page.dart';
import 'admin_add_user_page.dart';
import 'control_PAGE.dart';



class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    UserManagementPage(),
    AdminAddUserPage(),
    LogoutPage()
  ];

  void _onItmTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWilPop() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to exit the app?'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                child: const Text('Yes')),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWilPop,
      child: Scaffold(
        body: _children.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xff006AFA),
          unselectedItemColor: const Color(0xffBEBEBE),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'ADD User'), // <- New Item
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'LogOUt'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItmTapped,
          type: BottomNavigationBarType.fixed, // Important when more than 3 items
        ),
      ),
    );
  }
}
