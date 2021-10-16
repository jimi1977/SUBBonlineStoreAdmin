import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/widgets/progress_bar_widget.dart';

class ProductMaintenanceTabBarWidget<TabBar> extends StatefulWidget with PreferredSizeWidget {
  final TabController tabController;


  ProductMaintenanceTabBarWidget(this.tabController);

  @override
  _ProductMaintenanceTabBarWidgetState createState() => _ProductMaintenanceTabBarWidgetState();

  @override
  Size get preferredSize {
    return Size.fromHeight(50);
  }
}

class _ProductMaintenanceTabBarWidgetState extends State<ProductMaintenanceTabBarWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        ProgressBarWidget(),
        Container(
          child: TabBar(
            controller: widget.tabController,
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
                    "Product", style: TextStyle(fontSize: 14),
                  ),
                ),
                icon: Icon(Icons.add_to_home_screen_sharp),
              ),
              Tab(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Options", style: TextStyle(fontSize: 14),)),
                icon: Icon(Icons.input_rounded),
              ),
              Tab(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Variants", style: TextStyle(fontSize: 14),)),
                icon: Icon(Icons.qr_code_sharp),
              ),
              Tab(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Images", style: TextStyle(fontSize: 14),)),
                icon: Icon(Icons.image_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
