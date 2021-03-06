import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:invasive_fe/widgets/cameraHome.dart';
import 'package:invasive_fe/widgets/maps.dart';
import 'package:invasive_fe/widgets/userPage.dart';
import 'package:line_icons/line_icons.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  builder: (context, child) {
    return Directionality(textDirection: TextDirection.ltr, child: child!);
  },
  title: 'Uproot',
  theme: ThemeData(
    primaryColor: Colors.grey[800],
  ),
  home: Main()));

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 1;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static List<Widget> _widgetOptions = <Widget>[
    // Text(
    //   'Home',
    //   style: optionStyle,
    // ),
    // HttpTestPage(),
    MapsPage(),
    CameraHomePage(),
    UserPage()
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 20,
      //   title: const Text('InvasiveFE'),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.green[400]!,
              hoverColor: Colors.green[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.green[100]!,
              color: Colors.black,
              tabs: [
                // GButton(
                //   icon: LineIcons.users,
                //   text: 'Community',
                // ),
                GButton(
                  icon: LineIcons.map,
                  text: 'Map',
                ),
                GButton(
                  icon: LineIcons.retroCamera,
                  iconSize: 34,
                  text: 'Camera',
                ),
                GButton(
                  icon: LineIcons.userCircle,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
