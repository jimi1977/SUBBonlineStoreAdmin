import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/responsive/orientation_layout.dart';
import 'package:subbonline_storeadmin/responsive/screen_type_layout.dart';
import 'package:subbonline_storeadmin/screens/maintenance_page.dart';
import 'package:subbonline_storeadmin/screens/store_orders.dart';
import 'package:subbonline_storeadmin/services/shared_preferences_service.dart';
import 'package:subbonline_storeadmin/signin/signin_page.dart';
import 'package:subbonline_storeadmin/viewmodels/user_login_view_model.dart';
import 'package:subbonline_storeadmin/widgets/my_bottom_nav_bar.dart';

class SubbOnlineStoreHomePage extends StatefulWidget {
  final String title;
  @override
  _SubbOnlineStoreHomePageState createState() => _SubbOnlineStoreHomePageState();

  SubbOnlineStoreHomePage({@required this.title});
}

class _SubbOnlineStoreHomePageState extends State<SubbOnlineStoreHomePage> {
   int _currentIndex = 0;

   PageController _pageController = PageController();

   void _onItemTapped(int index) {
     _currentIndex = index;
     _pageController.jumpToPage(index);
   }

   void _onPageChanged(int selectedIndex) {
     _currentIndex = selectedIndex;
   }

   List<Widget> _screens = [
     StoreOrdersMain(pageIndex: 1,),
     StoreOrdersMain(pageIndex: 2,),
     MaintenancePage(pageIndex: 3,),
     StoreOrdersMain(pageIndex: 4,)
   ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      //DeviceOrientation.landscapeLeft
      //DeviceOrientation.portraitDown,
    ]);

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: ScreenTypeLayout(
          mobile: OrientationLayout(
            portrait: MyBottomNavBar(pageIndexFunction: _onItemTapped,),
            landscape: MyBottomNavBar(pageIndexFunction: _onItemTapped,),
          ),
          tablet: OrientationLayout(
            portrait: MyBottomNavBar(pageIndexFunction: _onItemTapped,),
            landscape: MyBottomNavBar(pageIndexFunction: _onItemTapped,),
          ),
          desktop: MyBottomNavBar(pageIndexFunction: _onItemTapped,),

        ),
        // appBar: AppBar(
        //   title: Text("My Store"),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.deepOrangeAccent
        // ),
        body: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: _onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        )

      ),
    );
  }


}




