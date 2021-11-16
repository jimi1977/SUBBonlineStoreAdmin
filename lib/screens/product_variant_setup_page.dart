import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/enums/viewstate.dart';
import 'package:subbonline_storeadmin/viewmodels/product_variant_viewmodel.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';

class ProductVariantSetupPage extends StatefulWidget {
  ProductVariantSetupPage({Key key}) : super(key: key);

  List<MaterialColor> randomColors = [];

  @override
  ProductVariantSetupPageState createState() => ProductVariantSetupPageState();
}

class ProductVariantSetupPageState extends State<ProductVariantSetupPage> {
  static final _formKey = GlobalKey<FormState>();

  List<TextEditingController> priceController = [];
  List<TextEditingController> surchargeController = [];
  List<TextEditingController> quantityController = [];

  List<String> _validationErrorText = [];

  double _width;

  String errorMessage = "Variants are not applicable based on your selection.";

  @override
  void initState() {
    // final model = context.read(productVariantViewModelProvider.notifier);
    // model.variantsLayout = buildVariants();
    super.initState();
  }

  Future<ConfirmAction> _asyncConfirmDialog({BuildContext context, String header, String alertMessage}) async {
    assert(header != null);
    assert(alertMessage != null);
    return showDialog<ConfirmAction>(
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CONFIRM);
              },
            )
          ],
        );
      },
    );
  }

  List<Widget> buildVariants() {
    errorMessage = "Variants are not applicable based on your selection.";
    final model = context.read(productVariantViewModelProvider.notifier);
    try {
      model.variants = model.prepareVariants();
    } on Exception catch (e) {
      errorMessage = e.toString();
    }
    if (model.variants != null) {
      return List.generate(
          model.variants.length, (index) => buildVariantInputLayout(model, index, model.variants[index]));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      if (_width <= 380)
      DeviceOrientation.landscapeLeft,
      if (_width > 380)
      DeviceOrientation.portraitDown,
    ]);
    return Consumer(builder: ((context, watch, _) {
      final state = watch(productVariantViewModelProvider);
      final model = watch(productVariantViewModelProvider.notifier);

      print("Width $_width");
      //if (model.variantsLayout == null) {
      model.variantsLayout = buildVariants();
//      }
      //model.variantsLayout = buildVariants();
      return model.variantsLayout == null || model.variantsLayout.length == 0
          ? Center(
              child: Container(
                child: Text("$errorMessage"),
              ),
            )
          : Container(
              child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: model.variantsLayout,
                ),
              ),
            ));
    }));
  }

  Widget buildColorBox(String color) {
    return Container(
      height: 25,
      width: 25,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 3, spreadRadius: 3)],
          color: Color(int.parse(color)),
          border: Border.all(color: Colors.black, width: 1, style: BorderStyle.solid)),
    );
  }

  buildTextControllers(index) {
    if (priceController.length < index + 1) {
      priceController.add(TextEditingController());
    }
    if (surchargeController.length < index + 1) {
      surchargeController.add(TextEditingController());
    }
    if (quantityController.length < index + 1) {
      quantityController.add(TextEditingController());
    }
    if (_validationErrorText.length < index + 1) {
      _validationErrorText.add(null);
    }
  }

  removeVariant(int index) {
    final model = context.read(productVariantViewModelProvider.notifier);
    if (index >= 0) {
      model.removeVariant(index);
    }
  }

  Widget buildVariantInputLayout(ProductVariantViewModel model, int index, ProductVariants productVariants) {
    buildTextControllers(index);
    MaterialColor randomColor;
    if (widget.randomColors.length > index) {
      randomColor = widget.randomColors[index];
    } else {
      randomColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
      widget.randomColors.add(randomColor);
    }

    String dismissibleKey = productVariants.productVariantId.toString();
    if (productVariants.unitValue != null) {
      dismissibleKey += productVariants.unitValue.toString();
    }
    if (productVariants.size != null) {
      dismissibleKey += productVariants.size;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Dismissible(
            direction: DismissDirection.startToEnd,
            key: Key(dismissibleKey),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                var _confirm = await _asyncConfirmDialog(
                    context: context, header: "Confirm", alertMessage: "Do you want to delete this variant?");
                if (_confirm == ConfirmAction.CONFIRM) {
                  return true;
                }
              }
              return false;
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                widget.randomColors.removeAt(index);
                removeVariant(index);

                //model.variantsLayout = buildVariants();
                model.setState(ViewState.Busy);
              }
            },
            background: Container(
              alignment: Alignment.centerLeft,
              color: randomColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.delete_forever_rounded,
                  size: 35,
                ),
              ),
            ),
            child: Material(
              elevation: 2,
              color: Colors.white,
              shadowColor: Colors.grey.shade500,
              child: Tooltip(
                message: "Swipe right to delete.",
                child: Container(
                  decoration: model.getBaseProductVariantId() == productVariants.productVariantId ? BoxDecoration(
                      border: Border.all(color: Colors.orangeAccent, width: 1.5),
                      borderRadius: BorderRadius.all(
                        Radius.circular(3),
                      )) : null,
                  child: Row(
                    children: [
                      Container(
                        color: randomColor,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("${productVariants.productVariantId}."),
                        ),
                      ),
                      if (productVariants.unitValue != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(width: 35, child: Text("${productVariants.unitValue}")),
                        ),
                      if (productVariants.size != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                              width: 20, child: FittedBox(fit: BoxFit.scaleDown, child: Text("${productVariants.size}"))),
                        ),
                      if (productVariants.color != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: buildColorBox(productVariants.color),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                        child: buildPriceInputWidget(model, index),
                      ),
                      Text(
                        "- OR -",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
                          child: buildSurchargeInputWidget(model, index)),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: buildQuantityInputWidget(model, index),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: buildMoreOptionButton(model, index),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_validationErrorText[index] != null)
            Text(
              _validationErrorText[index],
              style: kErrorTextStyle,
            )
        ],
      ),
    );
  }

  Widget buildPriceInputWidget(ProductVariantViewModel model, int index) {
    return CustomInputFormField(
      hintText: "0.0",
      labelText: "Price",
      labelTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
      //initialValue: model.variants[index].price == null ? null : model.variants[index].price.toString(),
      dbValue: getPrice(model, index),

      //prefixIcon: Icons.attach_money,
      prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
      textEditingController: priceController[index],
      textInputType: TextInputType.number,
      obscureText: false,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.end,
      autoFocus: false,
      enable: true,
      focusNode: null,
      maxLength: 12,
      width: _width * 19.44 / 100,
      height: 50,
      padding: const EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),
      //validateFunction: _validatePrice,
      //onSaveFunction: _priceSave,
      //onFieldSubmittedFunction: _node.nextFocus
    );
  }

  Widget buildSurchargeInputWidget(ProductVariantViewModel model, int index) {
    return CustomInputFormField(
      hintText: "0",
      labelText: "Surcharge",
      labelTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
      initialValue: model.variants[index].price == null ? null : model.variants[index].price.toString(),
      dbValue: getSurcharge(model, index),
      //prefixIcon: Icons.attach_money,
      prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
      textEditingController: surchargeController[index],
      textInputType: TextInputType.number,
      obscureText: false,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.end,
      autoFocus: false,
      enable: true,
      focusNode: null,
      maxLength: 12,
      width: _width * 19.444 / 100,
      height: 50,
      padding: const EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),
      //validateFunction: _validatePrice,
      //onSaveFunction: _priceSave,
      //onFieldSubmittedFunction: _node.nextFocus
    );
  }

  Widget buildQuantityInputWidget(ProductVariantViewModel model, int index) {
    return CustomInputFormField(
      //hintText: "1",
      labelText: "Qty",
      labelTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
      initialValue: model.variants[index].price == null ? null : model.variants[index].price.toString(),
      dbValue: getQuantity(model, index),
      //prefixIcon: Icons.attach_money,
      //prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
      textEditingController: quantityController[index],
      textInputType: TextInputType.number,
      obscureText: false,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.end,
      autoFocus: false,
      enable: true,
      focusNode: null,
      maxLength: 12,
      width: _width * 11.11 / 100,
      height: 50,
      padding: const EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),
      //validateFunction: _validatePrice,
      //onSaveFunction: _priceSave,
      //onFieldSubmittedFunction: _node.nextFocus
    );
  }

  Widget buildMoreOptionButton(ProductVariantViewModel model, int index) {
    return SizedBox(
      width: 30,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: PopupMenuButton(
            color: Colors.white,
            icon: Icon(Icons.more_vert, color: Colors.deepOrange,),
            padding:  const EdgeInsets.all(1),
            onSelected: (variantId) {
              model.setBaseProductVariant(variantId);
              model.setState(ViewState.Busy);
            },
            itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text("Set Base Product", style: kTextInputStyle,),
                    value: model.variants[index].productVariantId
                  ),
                ]),
      ),
    );
  }

  bool validateVariants() {
    final model = context.read(productVariantViewModelProvider.notifier);
    bool validated = true;
    int index = priceController.length;
    for (int i = 0; i < index; i++) {
      if (priceController[i].text == null || priceController[i].text.isEmpty) priceController[i].text = '0.0';
      if (surchargeController[i].text == null || surchargeController[i].text.isEmpty) surchargeController[i].text = '0.0';

      if ((priceController[i].text == null && surchargeController[i].text == null) ||
          (double.tryParse(priceController[i].text)  <= 0.0 && double.tryParse(surchargeController[i].text) <= 0.0)) {
        validated = false;
        print("Product Variants Validations");
        _validationErrorText[i] = "Both Price and Surcharge cannot be empty";
      } else {
        _validationErrorText[i] = null;
      }
      model.variantsLayout = buildVariants();
      model.setState(ViewState.Busy);
    }
    return validated;
  }

  String getPrice(ProductVariantViewModel model, int index) {
    if (model.variants != null && model.variants.length > 0 && model.variants.length >= index + 1) {
      return model.variants[index].price.toString();
    }
    return null;
  }

  String getSurcharge(ProductVariantViewModel model, int index) {
    if (model.variants != null && model.variants.length > 0 && model.variants.length >= index + 1) {
      return model.variants[index].surcharge.toString();
    }
    return null;
  }

  String getQuantity(ProductVariantViewModel model, int index) {
    if (model.variants != null && model.variants.length > 0 && model.variants.length >= index + 1) {
      return model.variants[index].quantity.toString();
    }
    return null;
  }

  bool saveVariants() {
    final model = context.read(productVariantViewModelProvider.notifier);
    if (!validateVariants()) {
      return false;
    }
    double _price;
    double _surcharge;
    int _qty;
    String _baseProduct;

    model.variantsToSave = [];
    int _length = model.variants.length;
    for (int idx = 0; idx < _length; idx++) {
      _price = double.tryParse(priceController[idx].text);
      _surcharge = double.tryParse(surchargeController[idx].text);
      _qty = int.tryParse(quantityController[idx].text);
      if (model.getBaseProductVariantId() == model.variants[idx].productVariantId) {
        print("Base Product ${model.variants[idx].productVariantId}");
        _baseProduct = "Y";
      }
      else _baseProduct = null;
      model.saveVariants(model.variants[idx], _price, _surcharge, _qty, _baseProduct);
    }
    return true;
  }
}
