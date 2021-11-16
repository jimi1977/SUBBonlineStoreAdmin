import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/services/measurement_units_service.dart';
import 'package:subbonline_storeadmin/services/product_color_service.dart';
import 'package:subbonline_storeadmin/viewmodels/product_options_view_model.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';

class ProductOptionsSetupPage extends StatefulWidget {
  const ProductOptionsSetupPage({Key key}) : super(key: key);

  @override
  ProductOptionsSetupPageState createState() => ProductOptionsSetupPageState();
}

class ProductOptionsSetupPageState extends State<ProductOptionsSetupPage>  {
  static final _formKey = GlobalKey<FormState>();
  final MeasurementUnitsService _measurementUnitsService = MeasurementUnitsService();

  final ProductColorService _productColorService = ProductColorService();

  double _width;

  String _measurementUnitErrorText;
  String _selectedSizeErrorText;
  String _selectedColorErrorText;

  bool isFormChanged = false;


  @override
  void initState() {
    super.initState();
  }

  List<DropdownMenuItem<String>> getMeasurementUnitsDropDownItems() {
    List<DropdownMenuItem<String>> items = [];

    var units = _measurementUnitsService.getUnits();
    units.forEach((element) {
      items.add(DropdownMenuItem(
          child: Text(
            element.name,
            style: kTextInputStyle,
          ),
          value: element.code));
    });
    return items;
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

  Widget buildSizesAvailable(ProductOptionsViewModel model) {
    return Container(
      //constraints: BoxConstraints.loose(Size(210, 30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: model.sizes == "Y",
            onChanged: (value) {
              setState(() {
                if (value) {
                  model.sizes = "Y";
                } else {
                  model.sizes = "N";
                }
              });
            },
          ),
          SizedBox(width: 120, child: Text("Contain Sizes")),
        ],
      ),
    );
  }

  Widget buildSalesTaxApplicable(ProductOptionsViewModel model) {
    return Container(
      //constraints: BoxConstraints.loose(Size(120, 30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: model.salesTax == "Y",
            onChanged: (value) {
              setState(() {
                if (value) {
                  model.salesTax = "Y";
                } else {
                  model.salesTax = "N";
                }
              });
            },
          ),
          SizedBox(width: 60, child: Text("Sales Tax")),
        ],
      ),
    );
  }

  Widget buildMaintainInventory(ProductOptionsViewModel model) {
    return Container(
      //constraints: BoxConstraints.loose(Size(170, 30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: model.maintainInventory == "Y",
            onChanged: (value) {
              setState(() {
                if (value) {
                  model.maintainInventory = "Y";
                } else {
                  model.maintainInventory = "N";
                }
              });
            },
          ),
          Text(
            "Maintain Inventory",
            style: kTextInputStyle,
          ),
        ],
      ),
    );
  }

  Widget buildColorsAvailable(ProductOptionsViewModel model) {
    return Container(
      //constraints: BoxConstraints.tight(Size(210, 30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: model.colors == "Y",
            onChanged: (value) {
              setState(() {
                if (value) {
                  model.colors = "Y";
                } else {
                  model.colors = "N";
                }
              });
            },
          ),
          SizedBox(width: 120, child: Text("Contains Colours")),
        ],
      ),
    );
  }

  Widget buildIsAccessory(ProductOptionsViewModel model) {
    return Container(
      //constraints: BoxConstraints.tight(Size(210, 30)),
      child: Row(
        children: [
          Checkbox(
            value: model.accessory == "Y",
            onChanged: (value) {
              setState(() {
                if (value) {
                  model.accessory = "Y";
                } else {
                  model.accessory = "N";
                }
              });
            },
          ),
          SizedBox(width: 160, child: Text("Accessory or Component")),
        ],
      ),
    );
  }

  Widget buildProductOptions(ProductOptionsViewModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Wrap(
        runAlignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.end,
        verticalDirection: VerticalDirection.down,
        //spacing: 2.0,
        //runSpacing: 2.0,
        alignment: WrapAlignment.start,

        children: [
          buildSizesAvailable(model),
          buildSalesTaxApplicable(model),
          buildColorsAvailable(model),
          buildMaintainInventory(model),
          buildIsAccessory(model),
        ],
      ),
    );
  }

  Widget buildInternalMeasurementUnitsDropDown(ProductOptionsViewModel model) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 75, maxWidth: 397),
      child: Visibility(
        visible: model.sizes == "Y",
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
          child: CustomDropDownWidget(
            key: _formKey,
            hintText: "Measurement Unit",
            errorText: _measurementUnitErrorText,
            helperText: "Please select measurement unit.",
            labelText: "Measurement Unit",
            prefixIcon: Icons.qr_code_sharp,
            prefixIconColor: Colors.orange,
            dropDownValues: getMeasurementUnitsDropDownItems(),
            selectedValue: model.selectedUnit,

            contentPadding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
            validatorFunction: validateMeasurementCode,
            //setValueFunction: saveIntCategoryCode,
            onChangeFunction: (value) {
              if (value != null) {
                setState(() {
                  model.selectedSizes = [];
                  model.selectedUnit = value;
                });
              }
              //_formChanged = true;
            },
            width: _width * 0.98,
            height: 62,
            //focusNode: _intCatCodeFocusNode,
            enable: true,
          ),
        ),
      ),
    );
  }

  Widget buildCustomSizeUnitsWidget(ProductOptionsViewModel model) {
    var _measurement = _measurementUnitsService.getMeasurementUnitProperties(model.selectedUnit);
    if (_measurement.customSizeRequired != null &&
        _measurement.customSizeRequired == "Y" &&
        model.selectedSizes != null &&
        model.selectedSizes.length > 0) {
      model.selectedColors = [];
      return CustomUnitsValuesWidget(
        selectedSizes: model.selectedSizes,
      );
    }
    return Container();
  }

  Widget buildSizeInputWidget(ProductOptionsViewModel model) {
    return Visibility(
      visible: model.sizes == "Y" && model.selectedUnit != null && model.selectedUnit.length > 0,
      child: Container(
        constraints: BoxConstraints.loose(Size(390, 500)),
        padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
        child: InputDecorator(
          decoration: InputDecoration(
              errorText: _selectedSizeErrorText,
              border: outlineInputBorder(Colors.grey),
              enabledBorder: outlineInputBorder(Colors.orangeAccent),
              focusedBorder: outlineInputBorder(Colors.blue),
              errorBorder: outlineInputBorder(Colors.red),
              disabledBorder: outlineInputBorder(Colors.grey),
              labelText: "Select available sizes"),
          child: Wrap(
            runAlignment: WrapAlignment.start,
            spacing: 2.0,
            runSpacing: 2.0,
            alignment: WrapAlignment.start,
            children: buildUnitsInput(model, model.selectedUnit),
          ),
        ),
      ),
    );
  }

  Widget buildColorsSelectionWidget(ProductOptionsViewModel model) {
    return Visibility(
      visible: model.colors != null && model.colors == "Y",
      child: Container(
        constraints: BoxConstraints.loose(Size(390, 500)),
        padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
        child: InputDecorator(
          decoration: InputDecoration(
              errorText: _selectedColorErrorText,
              border: outlineInputBorder(Colors.grey),
              enabledBorder: outlineInputBorder(Colors.orangeAccent),
              focusedBorder: outlineInputBorder(Colors.blue),
              errorBorder: outlineInputBorder(Colors.red),
              disabledBorder: outlineInputBorder(Colors.grey),
              labelText: "Select available colours"),
          child: Wrap(
              runAlignment: WrapAlignment.start,
              spacing: 2.0,
              runSpacing: 2.0,
              alignment: WrapAlignment.start,
              children: buildColorsSelection(model)),
        ),
      ),
    );
  }

  List<Widget> buildUnitsInput(ProductOptionsViewModel model, String value) {
    _selectedSizeErrorText = null;
    if (value != null && value.length > 1) {
      var unitSizes = _measurementUnitsService.getMeasurementUnitSizes(value);
      if (unitSizes != null && unitSizes.length == 1 && model.selectedSizes.length == 0) {
        model.selectedSizes.add(unitSizes[0].unit);
      }
      List<Widget> sizes = List.generate(unitSizes.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              child: Checkbox(
                  value: model.selectedSizes.indexOf(unitSizes[index].unit) >= 0,
                  onChanged: (value) {
                    if (value) {
                      model.selectedSizes.add(unitSizes[index].unit);
                    } else {
                      int idx = model.selectedSizes.indexOf(unitSizes[index].unit);
                      if (idx >= 0) {
                        model.selectedSizes.removeAt(idx);
                      }
                    }
                    setState(() {});
                  }),
            ),
            SizedBox(
                width: 65,
                child: Text(
                  "${unitSizes[index].name}",
                  style:
                  model.selectedSizes.indexOf(unitSizes[index].unit) >= 0 ? kTextInputStyle : kTextInputStyleGrey,
                )),
          ],
        );
      });
      return sizes;
    }
    return [];
  }

  List<Widget> buildColorsSelection(ProductOptionsViewModel model) {
    var productColors = _productColorService.getAvailableColors();

    List<Widget> sizes = List.generate(productColors.length, (index) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
                value: model.selectedColors.indexOf(productColors[index].color) >= 0,
                onChanged: (value) {
                  if (value) {
                    model.selectedColors.add(productColors[index].color);
                  } else {
                    int idx = model.selectedColors.indexOf(productColors[index].color);
                    if (idx >= 0) {
                      model.selectedColors.removeAt(idx);
                    }
                  }
                  setState(() {});
                }),
          ),
          buildColorBox(productColors[index].color),
          SizedBox(
            width: 10,
          ),
          Text(
            productColors[index].name,
            style:
            model.selectedColors.indexOf(productColors[index].color) >= 0 ? kTextInputStyle : kTextInputStyleGrey,
          ),
        ],
      );
    });
    return sizes;
  }

  bool saveProductOptions() {
    bool isSaved = true;
    _selectedColorErrorText = null;
    _selectedSizeErrorText = null;
    if (_formKey.currentState.validate()) {
      final model = context.read(productOptionsViewModelProvider.notifier);
      if (model.sizes == "Y" && (model.selectedSizes == null || model.selectedSizes.length == 0)) {
        _selectedSizeErrorText = "Please select available sizes";
      }
      if (model.colors == "Y" && (model.selectedColors == null || model.selectedColors.length == 0)) {
        _selectedColorErrorText = "Please select colour or uncheck contains colour checkbox";
      }
    }
    setState(() {});
    if (_selectedColorErrorText != null) {
      return false;
    }
    isFormChanged = false;
    return isSaved;
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      child: Form(
        key: _formKey,
        onChanged: () {
          isFormChanged = true;
        },
        child: SingleChildScrollView(
          child: Consumer(
            builder: ((context, watch, _) {
              final state = watch(productOptionsViewModelProvider);
              final model = watch(productOptionsViewModelProvider.notifier);
              populateScreen() {}
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildProductOptions(model),
                    SizedBox(
                      height: 10,
                    ),
                    buildInternalMeasurementUnitsDropDown(model),
                    SizedBox(
                      height: 10,
                    ),
                    buildSizeInputWidget(model),
                    SizedBox(
                      height: 10,
                    ),
                    buildCustomSizeUnitsWidget(model),
                    SizedBox(
                      height: 10,
                    ),
                    buildColorsSelectionWidget(model),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String validateMeasurementCode(String value) {
    final model = context.read(productOptionsViewModelProvider.notifier);
    if ((value == null || value.isEmpty) && model.sizes == "Y") return "Please select measurement unit.";
    return null;
  }
}

class CustomUnitsValuesWidget extends StatefulWidget {
  CustomUnitsValuesWidget({Key key, this.selectedSizes}) : super(key: key);

  final List<String> selectedSizes;

  @override
  _CustomUnitsValuesWidgetState createState() => _CustomUnitsValuesWidgetState();
}

class _CustomUnitsValuesWidgetState extends State<CustomUnitsValuesWidget> {
  List<TextEditingController> unitsValuesController = [];

  int noOfWidgets = 6;

  List<Widget> unitsValueInput;

  String _selectedUnit;

  @override
  void initState() {
    //noOfWidgets = widget.selectedSizes.length;
    final model = context.read(productOptionsViewModelProvider.notifier);
    if (widget.selectedSizes.length >= 0) {
      _selectedUnit = widget.selectedSizes[0];
    }
    if (model.selectedUnits == null || model.selectedUnits.length == 0) {
      model.selectedUnits = List.generate(noOfWidgets, (index) => _selectedUnit);
    }
    if (model.selectedUnitValue == null || model.selectedUnitValue.length == 0) {
      model.selectedUnitValue = List.generate(noOfWidgets, (index) => null);
    }


    generateInputWidget(model, noOfWidgets);

    super.initState();
  }

  @override
  void didUpdateWidget(CustomUnitsValuesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSizes.length != widget.selectedSizes.length) {
      print("didUpdateWidget Lengths differ");
      noOfWidgets = widget.selectedSizes.length;
      final model = context.read(productOptionsViewModelProvider.notifier);
      generateInputWidget(model, noOfWidgets);
    }
  }

  List<DropdownMenuItem<String>> getSelectableUnitsDownItems() {
    List<DropdownMenuItem<String>> items = [];

    if (widget.selectedSizes.length >= 0) {
      _selectedUnit = widget.selectedSizes[0];
    }

    widget.selectedSizes.forEach((element) {
      items.add(DropdownMenuItem(
          child: Text(
            element,
            style: kTextInputStyle,
          ),
          value: element));
    });
    return items;
  }

  String getUnitValue(ProductOptionsViewModel model, int index) {
    if (model.selectedUnitValue.length >= index + 1) {
      return model.selectedUnitValue[index];
    }
    return null;
  }

  generateInputWidget(ProductOptionsViewModel model, int noOfWidget) {
    unitsValueInput = List.generate(noOfWidget, (index) {
      unitsValuesController.add(TextEditingController());
      if (model.selectedUnitValue.length < index + 1) {
        model.selectedUnitValue.add(null);
      }
      if (model.selectedUnits.length < index + 1) {
        model.selectedUnits.add(_selectedUnit);
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 20, height: 15, margin: const EdgeInsets.symmetric(vertical: 16), child: Text("${index + 1} -")),
          CustomInputFormField(
            //hintText: "00",
            //labelText: "00",
            //initialValue: _price == null ? null : _price.toString(),
            //helperText: "Please enter quantity e.g. 100 grams or 1 Kg",
            //prefixIcon: Icons.workspaces_outline,
            //prefixIconConstraints: BoxConstraints.tight(Size(30, 30)),
            dbValue: getUnitValue(model, index),
            textEditingController: unitsValuesController[index],
            textInputType: TextInputType.number,
            obscureText: false,
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.end,
            autoFocus: false,
            focusNode: null,
            maxLength: 10,
            underLineInputBorder: true,
            width: 50,
            height: 30,
            padding: EdgeInsets.only(bottom: 1, top: 6, left: 5, right: 5),
            contentPadding: EdgeInsets.only(bottom: 6, top: 10, left: 1, right: 2),
            onChangeFunction: (value) {
              if (model.selectedUnitValue.length < index + 1) {
                if (model.selectedUnitValue.length >= noOfWidgets) {
                  model.selectedUnitValue.fillRange(model.selectedUnitValue.length - 1, index, null);
                }
                else {
                  for (int i = model.selectedUnitValue.length -1 ;i<index ; i++) {
                    model.selectedUnitValue.add(null);
                    model.selectedUnits.add(_selectedUnit);
                  }
                }
              }
              model.selectedUnitValue[index] = value;
            },
            //validateFunction: _validatePrice,
            //onSaveFunction: _priceSave,
            //onFieldSubmittedFunction: _node.nextFocus
          ),
          CustomDropDownWidget(
            //key: _formKey,
            //hintText: "Colours",
            //        errorText: _intCategoryValidationErrorText,
            //helperText: "Please select available product colours.",
            //labelText: "Unit",
            //prefixIcon: Icons.qr_co,
            prefixIconColor: Colors.orange,
            underLineInputBorder: true,
            dropDownValues: getSelectableUnitsDownItems(),
            selectedValue: index+1 <= model.selectedUnits.length ? model.selectedUnits[index] : null,
            padding: EdgeInsets.only(bottom: 8, top: 1, left: 5, right: 5),
            contentPadding: EdgeInsets.symmetric(horizontal: 1, vertical: 5),
            validatorFunction: (value) {

            },
            //setValueFunction: saveIntCategoryCode,
            onChangeFunction: (value) {
              if (model.selectedUnits.length < index + 1) {
                model.selectedUnits.add(value);
              }
              else {
                model.selectedUnits[index] = value;
              }

              //_formChanged = true;
            },
            width: 80,
            height: 40,
            //focusNode: _intCatCodeFocusNode,
            enable: true,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read(productOptionsViewModelProvider.notifier);
    generateInputWidget(model, noOfWidgets);

    return Container(
      child: Wrap(
          runAlignment: WrapAlignment.start,
          spacing: 2.0,
          runSpacing: 2.0,
          alignment: WrapAlignment.start,
          children: unitsValueInput),
    );
  }
}
