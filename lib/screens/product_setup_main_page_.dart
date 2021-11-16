import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/screens/product_options_setup_page.dart';
import 'package:subbonline_storeadmin/screens/product_setup_page.dart';
import 'package:subbonline_storeadmin/screens/product_variant_images_page.dart';
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
  GlobalKey<ProductVariantSetupPageState> _productVariantsKey = GlobalKey();

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
    if (_tabController.indexIsChanging) {
      print("Tab Index Changing $_currentIndex");
      if (_tabController.previousIndex == 2) {
        if (_productVariantsKey.currentState != null) {
          if (!_productVariantsKey.currentState.saveVariants()) {
            _tabController.animateTo(2, duration: Duration(milliseconds: 800));
            return;
          }
        }
      }

    }
  }

  Future<void> _asyncConfirmDialog({BuildContext context, String header, String alertMessage}) async {
    assert(header != null);
    assert(alertMessage != null);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            header,
            style: k16BoldBlack,
          ),
          content: Text(
            alertMessage,
            style: kTextInputStyle,
          ),
          buttonPadding: EdgeInsets.only(left: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Maintenance"),
        actions: [
          InkWell(
            onTap: () async {
              bool _isValidated = false;
              _isValidated = await _productKey.currentState.validateProduct();
              if (_isValidated) {
                if (_productOptionsKey.currentState != null) {
                  if (!_productOptionsKey.currentState.saveProductOptions()) {
                    _tabController.animateTo(1, duration: Duration(milliseconds: 800));
                    return;
                  }
                }

                if (_productVariantsKey.currentState != null) {
                  if (!_productVariantsKey.currentState.saveVariants()) {
                    _tabController.animateTo(2, duration: Duration(milliseconds: 800));
                    return;
                  }
                }
                  else {
                    _isValidated = _productKey.currentState.validateProductVariants();
                    if (!_isValidated) {
                      await _asyncConfirmDialog(context: context, header: "Validation Error", alertMessage: "Product Variants need to be configured. " );
                      _tabController.animateTo(2, duration: Duration(milliseconds: 800));
                      return;
                    }
                    _isValidated = _productKey.currentState.validateProductImages();
                    if (!_isValidated) {
                      await _asyncConfirmDialog(context: context, header: "Validation Error", alertMessage: "Either main product image or at least one variant image needs to be provided. ." );
                      _tabController.animateTo(0, duration: Duration(milliseconds: 800));
                      return;
                    }
                  }

                await _productKey.currentState.saveProductDetails();
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
                ),
              ),
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
                  ProductSetupPage(
                    key: _productKey,
                  ),
                  ProductOptionsSetupPage(key: _productOptionsKey),
                  ProductVariantSetupPage(
                    key: _productVariantsKey,
                  ),
                  ProductVariantImagesPage()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
