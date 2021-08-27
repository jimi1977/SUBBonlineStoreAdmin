import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/screens/branch_setup_page.dart';
import 'package:subbonline_storeadmin/widgets/store_branches_tabbar.dart';

import '../widgets/custom_tabbar_widget.dart';
import 'store_setup_page.dart';

class StoreBranchesMain extends StatefulWidget {
  const StoreBranchesMain({Key key}) : super(key: key);

  static const id = "store_branches_main";

  @override
  _StoreBranchesMainState createState() => _StoreBranchesMainState();
}

class _StoreBranchesMainState extends State<StoreBranchesMain> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: Text("Store Maintenance"),
              //backgroundColor: kMainPalette,
              centerTitle: true,
              bottom: StoreBranchesTabBar()),
          body: CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height - 56 - 130,
                  child: TabBarView(
                    children: <Widget>[
                      StoreSetupPage(),
                      BranchSetupPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
