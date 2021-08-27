



import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/widgets/order_filter_input_widget.dart';
import 'package:subbonline_storeadmin/widgets/orders_list_filter.dart';

class OrderSearchPage extends StatelessWidget {
  static const id = "store_search_page";

  const OrderSearchPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search"),
        ),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            _buildSearchCriteria()
          ],

        ),
      ),
    );
  }

  Widget _buildSearchCriteria() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FilterInputWidget(applyFilterFunction: (){},),
      ),

    );

  }
}
