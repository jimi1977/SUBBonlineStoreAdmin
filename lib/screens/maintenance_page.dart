import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';



class MaintenancePage extends StatelessWidget {
  static const id = "maintenance_page";

  final int pageIndex;

  MaintenancePage({Key key, this.pageIndex}) : super(key: key);
  List<QuiltedGridTile> _staggeredTiles = <QuiltedGridTile>[
    QuiltedGridTile(2, 2), //Products
    QuiltedGridTile(2, 1), //Update Price
    QuiltedGridTile(2, 1), //Update Price
    QuiltedGridTile(3, 1), //Store
    QuiltedGridTile(2, 2), //Main Category
    QuiltedGridTile(1, 2), //Category


    // StaggeredTunt(1, 2),
    // StaggeredTunt(1, 1),
    QuiltedGridTile(1, 1), //Brand
    QuiltedGridTile(1, 1), //Sizes
    QuiltedGridTile(3, 1), //Users
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
      routeName: "product_setup_main_page",
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
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.brown,
      menuIcon: Icons.map,
      menuName: "Main Categories",
      routeName: 'main_category_setup_page',
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.deepOrange,
      menuIcon: Icons.category,
      menuName: "Categories",
      routeName: "category_setup_page",
      onTapAction: () {},
      enabled: true,
    ),
    _MenuItemTile(
      backGroundColor: Colors.indigo,
      menuIcon: Icons.branding_watermark_outlined,
      menuName: "Brands",
      routeName: "brand_setup_page",
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

    return GridView.count(crossAxisCount: 2,
    children: _tiles,);

    return GridView.custom(
      gridDelegate: SliverQuiltedGridDelegate(


        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        repeatPattern: QuiltedGridRepeatPattern.inverted,

        pattern: _staggeredTiles,
      ),

      childrenDelegate: SliverChildBuilderDelegate(

            (context, index) => _tiles[index]
      ),
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
