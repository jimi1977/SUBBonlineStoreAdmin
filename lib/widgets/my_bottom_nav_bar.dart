

import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/screens/store_orders.dart';

class MyBottomNavBar extends StatefulWidget {

  final Function pageIndexFunction;

  MyBottomNavBar({this.pageIndexFunction});

  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  var _currentIndex = 0 ;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      elevation: 2,
      backgroundColor: Colors.redAccent,
      items: const <BottomNavigationBarItem> [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home", tooltip: "Home",),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Orders",tooltip: "Orders"),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: "Maintenance", ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: "More"),

      ],
      selectedItemColor: Colors.redAccent,
      selectedFontSize: 13,
      unselectedItemColor: Colors.grey,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      onTap: (index){
        setState(() {
          _currentIndex = index;
          widget.pageIndexFunction(index);

        });


      },

    );
  }
}
