import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/widgets/progress_bar_widget.dart';

class OrdersTabBarWidget<TabBar> extends StatefulWidget with PreferredSizeWidget {
  @override
  _OrdersTabBarWidgetState createState() => _OrdersTabBarWidgetState();

  @override
  Size get preferredSize {
    return Size.fromHeight(50);
  }
}

class _OrdersTabBarWidgetState extends State<OrdersTabBarWidget> {
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
                    "New Orders", style: TextStyle(fontSize: 14),
                  ),
                ),
                icon: Icon(Icons.mark_chat_unread_outlined),
              ),
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                    child: Text("Ongoing Orders", style: TextStyle(fontSize: 14),)),
                icon: Icon(Icons.input_rounded),
                //icon: Icon(Icons.beach_access_sharp),
              ),
              Tab(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Past Orders", style: TextStyle(fontSize: 14),)),
                icon: Icon(Icons.history),
                //icon: Icon(Icons.brightness_5_sharp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
