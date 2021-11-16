import 'package:flutter/material.dart';
import 'package:models/deals.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/viewmodels/product_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DealsWidget extends StatefulWidget {
  final ProductViewModel model;

  Deals selectedDeal;

  DealsWidget({@required this.model});

  @override
  _DealsWidgetState createState() => _DealsWidgetState();
}

class _DealsWidgetState extends State<DealsWidget> {
  Future<List<Deals>> deals;

  @override
  void initState() {
    deals = widget.model.getDeals();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    deals = null;
  }

  OutlineInputBorder _outlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(5.0),
          bottomLeft: Radius.circular(5.0),
          topLeft: Radius.circular(5.0),
          topRight: Radius.circular(5.0),
        ));
  }

  static final TextEditingController dealValueEditingController = TextEditingController();

  bool _enable = true;

  @override
  Widget build(BuildContext context) {
    print("=========== DealsWidget Build Method ============");

    final  model = context.read(productViewModelProvider.notifier);

    if (model.getDeals() != null) {
      widget.selectedDeal = model.deal;
    }

    List<DropdownMenuItem<Deals>> _getBrandsDropDown(List<Deals> deals) {
      List<DropdownMenuItem<Deals>> items = new List();
      items.add(DropdownMenuItem(child: Text(""), value: null));
      if (deals != null) {
        for (var deal in deals) {
          items.add(DropdownMenuItem(child: Text(deal.name), value: deal));
        }
        if (model.getDeals() != null) {
          widget.selectedDeal = model.deal;
        }
      }
      return items;
    }

    Widget _buildDealsProperties(Deals deals) {
      print("Deal Value ${deals.dealValue.toString()}");
      dealValueEditingController.text = deals.dealValue.toString();
      return Container(
        height: 60,
        width: 40,
        child: TextField(
          textAlign: TextAlign.right,
          keyboardType: TextInputType.number,
          controller: dealValueEditingController,
            enabled: _enable,
          onChanged: (value) {
            double dealValue = double.tryParse(value);
            Deals _localDeals = Deals(id: deals.id, name: deals.name, type: deals.type, dealValue: dealValue);
            model.deal = _localDeals;
          },
          decoration: InputDecoration(
            disabledBorder: _outlineInputBorder(Colors.grey),
            enabledBorder: _outlineInputBorder(Colors.orangeAccent),
            focusedErrorBorder: _outlineInputBorder(Colors.redAccent),
            errorBorder: _outlineInputBorder(Colors.redAccent),
            focusedBorder: _outlineInputBorder(Colors.blueAccent),
            contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 10),
            suffixText: model.deal != null && model.deal.type == "SM" ? "" : "%",
            suffixStyle: TextStyle(fontSize: 16),
          ),
        ),
      );

    }

    Widget _buildDealInputForm() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width * 0.5,
            child: FormField(
              enabled: true,
              builder: (FormFieldState state) {
                return InputDecorator(
                  expands: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    filled: false,
                    hintText: "Choose Deal",
                    disabledBorder: _outlineInputBorder(Colors.grey),
                    enabledBorder: _outlineInputBorder(Colors.orangeAccent),
                    focusedErrorBorder: _outlineInputBorder(Colors.redAccent),
                    errorBorder: _outlineInputBorder(Colors.redAccent),
                    focusedBorder: _outlineInputBorder(Colors.blueAccent),
                  ),
                  child: Container(
                    height: 30,
                    child: DropdownButtonHideUnderline(
                      child: FutureBuilder<List<Deals>>(
                          future: deals,
                          builder: (context, AsyncSnapshot<List<Deals>> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent)),
                                ),
                              );
                            }
                            return DropdownButton<Deals>(
                              elevation: 1,
                              style: kTextInputStyle,
                              items: _getBrandsDropDown(snapshot.data),
                              value: widget.selectedDeal,
                              onChanged: (Deals value) {
                                setState(() {
                                  widget.selectedDeal = value;
                                  model.deal = widget.selectedDeal;
                                  if (value.type == "H" || value.type == "B1F1" || value.type == "S50S") {
                                    _enable = false;
                                  } else _enable = true;
                                  //print("Selected Value $selectedDeal");
                                  //Display Selected Values
                                });
                              },
                            );
                          }),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.selectedDeal != null)
            Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: _buildDealsProperties(model.deal),
                ))
        ],
      );
    }

    return _buildDealInputForm();
  }
}