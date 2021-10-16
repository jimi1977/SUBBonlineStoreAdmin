import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/screens/product_options_setup_page.dart';
import 'package:subbonline_storeadmin/screens/product_setup_page.dart';
import 'package:subbonline_storeadmin/screens/product_variant_setup_page.dart';
import 'package:subbonline_storeadmin/widgets/product_maintenacne_tabbar_widget.dart';

class ProductSetupMainPage extends StatefulWidget {
  static const id = "product_setup_main_page";

  const ProductSetupMainPage({Key key}) : super(key: key);

  @override
  _ProductSetupMainPageState createState() => _ProductSetupMainPageState();
}

class _ProductSetupMainPageState extends State<ProductSetupMainPage> with TickerProviderStateMixin {
  int _index = 0;

  TabController _tabController;

  int _currentIndex;

  GlobalKey<ProductSetupPageState> _productKey = GlobalKey();
  GlobalKey<ProductOptionsSetupPageState> _productOptionsKey = GlobalKey();


  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);

    _tabController.addListener(() {
      _handleTabSelection();
    });

    super.initState();
  }

  _handleTabSelection() {
    _currentIndex = _tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Maintenance"),
        actions: [
          InkWell(
            onTap: () async {
              if (await _productKey.currentState.saveProductDetails())  {
                if (_productOptionsKey.currentState != null) {
                  if (!_productOptionsKey.currentState.saveProductOptions()) {
                    _tabController.animateTo(1 , duration: Duration(milliseconds: 800));
                  }
                }
              }
              else {
                _tabController.animateTo(0 , duration: Duration(milliseconds: 800));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                  message: "Save",
                  child: Icon(
                    Icons.save,
                    color: Colors.blue,
                    size: 28,
                  ),),
            ),
          ),
        ],
        bottom: ProductMaintenanceTabBarWidget(_tabController),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height - 56 - 130,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ProductSetupPage(key: _productKey,),
                  ProductOptionsSetupPage(key:_productOptionsKey),
                  ProductVariantSetupPage(),
                  Center(child: Text("Images"))

                ],

              ),
            ),
          )
        ],




      ),
    );
  }
}
