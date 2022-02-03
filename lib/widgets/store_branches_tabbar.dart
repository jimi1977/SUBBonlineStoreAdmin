


import 'package:flutter/material.dart';

class StoreBranchesTabBar extends StatefulWidget with PreferredSizeWidget {
  const StoreBranchesTabBar({Key key}) : super(key: key);

  @override
  _StoreBranchesTabBarState createState() => _StoreBranchesTabBarState();

  @override
  Size get preferredSize {
    return Size.fromHeight(50);
  }
}

class _StoreBranchesTabBarState extends State<StoreBranchesTabBar> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      child: TabBar(

        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          insets: EdgeInsets.all(4),
          borderSide: BorderSide(color: Colors.green, width: 3.0),
        ),
        unselectedLabelColor: Colors.grey,
        automaticIndicatorColorAdjustment: true,
        labelColor: Color(0xFFFF6D05),//kMainPalette,
        indicatorColor: Colors.green,
        physics: BouncingScrollPhysics(),
        tabs: <Widget>[
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Store", style: TextStyle(fontSize: 14),
              ),
            ),
            icon: Icon(Icons.account_balance_outlined),
          ),
          Tab(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("Branch", style: TextStyle(fontSize: 14),)),
            icon: Icon(Icons.storefront),
            //icon: Icon(Icons.beach_access_sharp),
          )
        ],
      ),
    );
  }
}
