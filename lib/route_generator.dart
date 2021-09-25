import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:subbonline_storeadmin/screens/brands_setup_page.dart';
import 'package:subbonline_storeadmin/screens/main_category_setup_page.dart';
import 'package:subbonline_storeadmin/screens/my_order_details.dart';
import 'package:subbonline_storeadmin/screens/order_search_page.dart';
import 'package:subbonline_storeadmin/screens/store_branches_main.dart';
import 'package:subbonline_storeadmin/screens/store_orders.dart';
import 'package:subbonline_storeadmin/screens/store_setup_page.dart';
import 'package:subbonline_storeadmin/screens/user_list_page.dart';
import 'package:subbonline_storeadmin/screens/user_maintenance_page.dart';
import 'package:subbonline_storeadmin/signin/authwidget.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AuthWidget.id:
        return MaterialPageRoute(builder: (_) => AuthWidget());

      case StoreOrdersMain.id:
        return MaterialPageRoute(builder: (_) => StoreOrdersMain());

      case MyOrderDetails.id:
        if (args.runtimeType == Order) {
          return MaterialPageRoute(builder: (_) => MyOrderDetails(
            order: args,
          )
          );
        }
        return _errorRoute();

      case OrderSearchPage.id:
        return MaterialPageRoute(builder: (_) => OrderSearchPage());
      case UserMaintenancePage.id:
        return MaterialPageRoute(builder: (_) => UserMaintenancePage());

      case UsersListPage.id:
        return MaterialPageRoute<StoreUsers>(builder: (_) => UsersListPage());
      case StoreSetupPage.id:
        return MaterialPageRoute(builder: (_) => StoreSetupPage());
      case StoreBranchesMain.id:
        return MaterialPageRoute(builder: (_) => StoreBranchesMain());
      case BrandsPageSetup.id:
        return MaterialPageRoute(builder: (_) => BrandsPageSetup());
      case MainCategorySetupPage.id:
        return MaterialPageRoute(builder: (_) => MainCategorySetupPage());


      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}


