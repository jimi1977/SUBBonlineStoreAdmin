import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';



class MaintenancePage extends StatelessWidget {
  static const id = "maintenance_page";

  final int pageIndex;

  MaintenancePage({Key key, this.pageIndex}) : super(key: key);
  List<StaggeredTile> _staggeredTiles = <StaggeredTile>[
    StaggeredTile.count(2, 2), //Products
    StaggeredTile.count(2, 1), //Update Price
    StaggeredTile.count(2, 1), //Update Price
    StaggeredTile.count(4, 1), //Store
    StaggeredTile.count(2, 2), //Main Category
    StaggeredTile.count(1, 2), //Category


    // StaggeredTile.count(1, 2),
    // StaggeredTile.count(1, 1),
    StaggeredTile.count(1, 1), //Brand
    StaggeredTile.count(1, 1), //Sizes
    StaggeredTile.count(4, 1), //Users
  ];
  List<String> _menuItems = [
    'Product',
    'Update Price',
    'Store',
    'Main Category',
    'Category',
    'Brand',
    'Sizes',
    'Users'
  ];
  List<Widget> _tiles = <Widget>[
    _MenuItemTile(
      backGroundColor: Colors.green,
      menuIcon: Icons.widgets,
      menuName: "Products",
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.lightBlue,
      menuIcon: Icons.monetization_on_outlined,
      menuName: "Update Price",
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.lightGreen,
      menuIcon: Icons.money_off,
      menuName: "Deals",
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.amber,
      menuIcon: Icons.panorama_wide_angle,
      menuName: "Store",
      routeName: "store_branches_main",
      onTapAction: () {},
      enabled: false,
    ),
    _MenuItemTile(
      backGroundColor: Colors.brown,
      menuIcon: Icons.map,
      menuName: "Main Categories",
      onTapAction: () {},
      enabled: false,
    ),
    _MenuItemTile(
      backGroundColor: Colors.deepOrange,
      menuIcon: Icons.category,
      menuName: "Categories",
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.indigo,
      menuIcon: Icons.branding_watermark_outlined,
      menuName: "Brands",
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.red,
      menuIcon: Icons.format_size_outlined,
      menuName: "Sizes",
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.pink,
      menuIcon: Icons.supervised_user_circle_sharp,
      menuName: "Users",
      routeName: "user_maintenance_page",
      onTapAction: () {

      },
      enabled: true,
    ),

    // _MenuItemTile(Colors.purple, Icons.desktop_windows),
    // _MenuItemTile(Colors.blue, Icons.radio),
  ];

  final _random = Random();

  Widget buildMaintenanceMenu() {
    return StaggeredGridView.count(

      crossAxisCount: 4,
      staggeredTiles: _staggeredTiles,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: const EdgeInsets.all(4),
      children: _tiles,
      shrinkWrap: true,

    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Maintenance"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
                child: buildMaintenanceMenu()),
          )),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final String menuName;
  final IconData menuIcon;
  final Color backGroundColor;
  final String routeName;
  final Function onTapAction;
  final bool enabled;

  _MenuItemTile({this.menuName, this.menuIcon, this.backGroundColor, this.onTapAction, this.enabled,this.routeName });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //onTapAction();
        if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Card(
        color: backGroundColor,
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                menuIcon,
                color: enabled ? Colors.white : Colors.grey,
              ),
            ),
            Text(
              menuName,
              style: TextStyle(color: enabled ? Colors.white : Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
