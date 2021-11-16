import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:models/shelf.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/viewmodels/product_image_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/store_view_model.dart';
import 'package:subbonline_storeadmin/widgets/animated_button.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';
import 'package:subbonline_storeadmin/widgets/deals_widget.dart';
import 'package:subbonline_storeadmin/widgets/product_images_view.dart';

class ProductSetupPage extends StatefulWidget {
  const ProductSetupPage({Key key}) : super(key: key);

  @override
  ProductSetupPageState createState() => ProductSetupPageState();
}

class ProductSetupPageState extends State<ProductSetupPage> with AutomaticKeepAliveClientMixin {
  static final _formKey = GlobalKey<FormState>();

  TextEditingController productNameTextController = TextEditingController();
  TextEditingController productNameIntlTextController = TextEditingController();
  TextEditingController skuTextController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController manufacturerLinkController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController searchTagsController = TextEditingController();

  String _categoryValidationErrorText;
  String _brandValidationErrorText;

  String _selectedCategory;
  String _selectedBrand;

  String _productName;

  String _productIntlName;

  String _sku;

  int _quantity;

  String _brandValidationError;

  double _price;

  String _productDescription;

  String _manufacturerLink;

  String _searchTags;

  String _searchTag1;
  String _searchTag2;
  String _searchTag3;

  String _storeCode;

  bool _isProductExist = false;
  bool _formSaved = false;
  bool isFormChanged = false;

  String _productId;

  DateTime _addedDateTime;

  List<ProductImage> productImages = [];
  List<String> retrievedImages = [];
  List<String> specifications = [];

  @override
  bool get wantKeepAlive => true;

  var _fieldDecoration = BoxDecoration(
      border: Border.all(color: Colors.orangeAccent, width: 1.2),
      borderRadius: BorderRadius.all(
        Radius.circular(3),
      ));

  String extractSearchTags(List<String> searchTag1, List<String> searchTag2, List<String> searchTag3) {
    String _searchTags;
    if (searchTag1 != null && searchTag1.length > 0) {
      _searchTags = searchTag1.last;
    }
    if (searchTag2 != null && searchTag2.length > 0) {
      _searchTags = _searchTags + "," + searchTag2.last;
    }
    if (searchTag3 != null && searchTag3.length > 0) {
      _searchTags = _searchTags + "," + searchTag3.last;
    }
    return _searchTags;
  }

  double _width;

  Stream<List<Category>> categories;
  Stream<List<Brands>> brands;

  @override
  void initState() {
    final model = context.read(productViewModelProvider.notifier);
    categories = model.getCategoriesStream();
    brands = model.getBrandsStream();
    super.initState();
  }

  Future<bool> validateProduct() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return true;
    } else
      return false;
  }

  bool validateProductVariants() {
    final model = context.read(productViewModelProvider.notifier);
    return model.validateProductVariants();
  }
  bool validateProductImages() {
    final model = context.read(productViewModelProvider.notifier);
    model.productImages = productImages;
    return model.validateProductImages();
  }

  Future<bool> saveProductDetails() async {
    await EasyLoading.show(
      status: 'Saving...',
      maskType: EasyLoadingMaskType.clear,
    );
    final model = context.read(productViewModelProvider.notifier);
    final storeViewModel = context.read(storeViewModelProvider.notifier);
    var _store = await storeViewModel.getMyStore();
    model.productId = _productId;
    model.productName = _productName;
    model.productIntlName = _productIntlName;
    model.sku = _sku;
    model.quantity = _quantity;
    model.price = _price;
    model.selectedBrand = _selectedBrand;
    model.selectedCategory = _selectedCategory;
    model.selectedStore = _storeCode;
    model.description = _productDescription;
    model.manufacturerLink = _manufacturerLink;
    model.searchTag1 = _searchTag1;
    model.searchTag2 = _searchTag2;
    model.searchTag3 = _searchTag3;
    model.productImages = productImages;
    model.retrievedImages = retrievedImages;
    model.specifications = specifications;
    if (_addedDateTime == null) {
      _addedDateTime = DateTime.now();
    }
    model.addedDateTime = _addedDateTime;
    if (_storeCode == null) {
      _storeCode = _store.store;
    }
    if (model.selectedStore == null) {
      model.selectedStore = _storeCode;
    }
    bool isProductSaved = await model.saveProductDetails();
    EasyLoading.dismiss();
    if (isProductSaved) {
      if (_isProductExist) {
        displayMessage(context, "Product Information Updated");
      } else
        displayMessage(context, "Product Information Saved");

      _formSaved = true;
      isFormChanged = false;
      return true;
    } else if (isProductSaved == false) {
      _formSaved = false;
      displayMessage(context, model.errorMessage);
    }

    return isProductSaved;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    _width = MediaQuery.of(context).size.width;
    return Container(
        child: Form(
      key: _formKey,
      onChanged: () {
        isFormChanged = true;
      },
      child: SingleChildScrollView(
        child: Consumer(
          builder: ((context, watch, _) {
            final state = watch(productViewModelProvider);
            final model = watch(productViewModelProvider.notifier);

            void _copyImageOnModel(List<ProductImage> productImages) {
              model.productImages = productImages;
              this.productImages = productImages;
            }


            initialise() {
              productNameTextController.clear();
              productNameIntlTextController.clear();
              skuTextController.clear();
              quantityController.clear();
              priceController.clear();
              manufacturerLinkController.clear();
              descriptionController.clear();
              searchTagsController.clear();
              _productId = null;
              _selectedBrand = null;
              _selectedCategory = null;
              _storeCode = null;
              _isProductExist = false;
              isFormChanged = false;
              productImages = null;
              retrievedImages = null;
              _addedDateTime = null;
              specifications = [];
              model.initialise();
              model.rebuildState();
            }

            populateForm(Product product) {
              model.initialise();
              productNameTextController.text = product.name;
              productNameIntlTextController.text = product.intlName;
              skuTextController.text = product.sku;
              quantityController.text = product.quantity.toString();
              priceController.text = product.price.toString();
              manufacturerLinkController.text = product.manufacturerLink;
              descriptionController.text = product.description;
              searchTagsController.text = extractSearchTags(product.searchTag1, product.searchTag2, product.searchTag3);
              model.product = product;
              model.productId = product.productId;
              _productId = product.productId;
              productImages = product.imageUrl.map((e) => ProductImage(downloadURL: e)).toList();
              model.productImages = product.imageUrl.map((e) => ProductImage(downloadURL: e)).toList();
              if (productImages.length > 0) {
                retrievedImages = model.productImages.map((e) => e.downloadURL).toList();
                model.retrievedImages = model.productImages.map((e) => e.downloadURL).toList();
              }
              _selectedBrand = product.brand.path;
              _selectedCategory = product.category.path;
              _storeCode = product.storeId;
              specifications = product.specifications == null ? [] : product.specifications;
              _addedDateTime = product.addedDateTime;
              _isProductExist = true;
              isFormChanged = false;
              model.populatedProviders();

              model.rebuildState();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.loose(Size(396, 72)),
                  child: Container(
                    width: _width * 0.98,
                    //height: 50,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 5, top: 5, left: 8, right: 5),
                      child: TypeAheadFormField(
                        textFieldConfiguration: TextFieldConfiguration(
                            controller: productNameTextController,
                            style: TextStyle(fontSize: 14),
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () async {
                              //await retrieveIfExists(productNameTextController.text);
                              // var nextFocus = _node.nextFocus;
                              // nextFocus.call();
                              // _nextFieldFocus.requestFocus();
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                              border: outlineInputBorder(Colors.grey),
                              enabledBorder: outlineInputBorder(Colors.orangeAccent),
                              focusedBorder: outlineInputBorder(Colors.blue),
                              errorBorder: outlineInputBorder(Colors.red),
                              disabledBorder: outlineInputBorder(Colors.grey),
                              hintText: "Product Name",
                              hintStyle: TextStyle(fontSize: 14),
                              labelText: "Product Name",
                              labelStyle: TextStyle(fontSize: 14),
                              prefixIcon: Padding(
                                padding: const EdgeInsetsDirectional.only(start: 0.0),
                                child: Icon(
                                  Icons.android,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  initialise();
                                  //model.rebuildWidget();
                                },
                                child: Icon(
                                  Icons.clear,
                                  size: 18,
                                ),
                              ),
                            )),
                        suggestionsCallback: (pattern) async {
                          return await model.getProductsForSearchList(pattern.toLowerCase());
                        },
                        transitionBuilder: (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        itemBuilder: (context, Product suggestion) {
                          return SizedBox(
                            height: 75,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: suggestion.imageUrl != null && suggestion.imageUrl.length > 0
                                      ? SizedBox(width: 30, height: 30, child: Image.network(suggestion.imageUrl[0]))
                                      : SizedBox(
                                          width: 30,
                                          height: 30,
                                        ),
                                  title: Text('${suggestion.name}'),
                                  trailing: Text('${suggestion.intlName}'),
                                  subtitle: Text('$kGlobalCurrency ${suggestion.price}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Divider(
                                    height: 1,
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        onSuggestionSelected: (Product suggestion) {
                          productNameTextController.text = suggestion.name;
                          populateForm(suggestion);
                          //_isProductExist = true;
                        },
                        keepSuggestionsOnLoading: true,
                        hideSuggestionsOnKeyboardHide: true,
                        noItemsFoundBuilder: (context) {
                          return null;
                        },
                        validator: (value) {
                          if (value.isEmpty) return "Product Name can not be empty";
                          if (value.length <= 1) return "Product Name should be more than 1 character.";
                          return null;
                        },
                        onSaved: _productNameSave,
                      ),
                    ),
                  ),
                ),
                Row(children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: CustomInputFormField(
                      hintText: 'اردو میں نام',
                      labelText: 'اردو میں نام',
//                          initialValue: _productIntlName,
                      prefixIcon: Icons.translate,
                      autoFocus: false,
                      textEditingController: productNameIntlTextController,
                      textInputType: TextInputType.text,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      padding: EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
                      obscureText: false,
                      textInputAction: TextInputAction.next,
                      width: _width * 0.70,
                      height: 50,
//                          focusNode: _nextFieldFocus,
                      validateFunction: null,
                      onSaveFunction: _productIntlNameSave,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10, top: 5, left: 20, right: 1),
                    height: 50,
                    width: 80,
                    child: RawMaterialButton(
                      fillColor: Colors.blueAccent,
                      //constraints: BoxConstraints(maxHeight: 50, maxWidth: 80),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      child: Image.asset("images/misc/translate.png"),

                      onPressed: () async {
                        var _productNameInt = productNameTextController.text;
                        if (_productNameInt.isEmpty) return;
                        var translation = await model.translateString(_productNameInt);
                        productNameIntlTextController.text = translation.text;
                      },
                    ),
                  ),
                ]),
                buildProductCategoryDropDown(),
                buildProductBrandDropDown(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: CustomInputFormField(
                        hintText: "SKU",
                        labelText: "SKU",
                        //initialValue: _sku,
                        prefixIcon: Icons.assignment,
                        prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
                        textEditingController: skuTextController,
                        textInputType: TextInputType.text,
                        obscureText: false,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.end,
                        focusNode: null,
                        padding: EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 5),
                        autoFocus: false,
                        width: 135,
                        height: 50,
                        validateFunction: null,
                        onSaveFunction: _skuSave,
                        //onFieldSubmittedFunction: _node.nextFocus
                      ),
                    ),
                    Expanded(
                      child: CustomInputFormField(
                        hintText: "Quantity",
                        labelText: "Quantity",
                        //initialValue: _quantity == null ? null : _quantity.toString(),
                        prefixIcon: Icons.insert_chart,
                        prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
                        textEditingController: quantityController,
                        textInputType: TextInputType.number,
                        obscureText: false,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.end,
                        autoFocus: false,
                        focusNode: null,
                        maxLength: 5,
                        width: 135,
                        height: 50,
                        padding: EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 5),
                        validateFunction: null,
                        onSaveFunction: _quantitySave,
                        //onFieldSubmittedFunction: _node.nextFocus
                      ),
                    ),
                    Expanded(
                      child: CustomInputFormField(
                        hintText: "Price",
                        labelText: "Price",
                        //initialValue: _price == null ? null : _price.toString(),
                        prefixIcon: Icons.attach_money,
                        prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
                        textEditingController: priceController,
                        textInputType: TextInputType.number,
                        obscureText: false,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.end,
                        autoFocus: false,
                        focusNode: null,
                        maxLength: 12,
                        width: 135,
                        height: 70,
                        padding: EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 5),
                        validateFunction: _validatePrice,
                        onSaveFunction: _priceSave,
                        //onFieldSubmittedFunction: _node.nextFocus
                      ),
                    ),
                  ],
                ),

                CustomInputFormField(
                  hintText: "Manufacturer's site link",
                  labelText: "Manufacturer's site link",
                  //initialValue: _manufacturerLink,
                  prefixIcon: Icons.http,
                  textEditingController: manufacturerLinkController,
                  textInputType: TextInputType.text,
                  obscureText: false,
                  textInputAction: TextInputAction.next,
                  minLines: 1,
                  maxLines: 1,
                  autoFocus: false,
                  focusNode: null,
                  width: _width * 0.95,
                  height: 50,
                  padding: const EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 5),
                  //validateFunction:
                  onSaveFunction: _saveManufacturerLink,
                  //onFieldSubmittedFunction: _node.nextFocus
                ),

                //Description
                CustomInputFormField(
                  hintText: "Description",
                  labelText: "Description",
                  //initialValue: _productDescription,
                  prefixIcon: Icons.assignment,
                  textEditingController: descriptionController,
                  textInputType: TextInputType.text,
                  obscureText: false,
                  textInputAction: TextInputAction.next,
                  minLines: 6,
                  maxLines: 10,
                  autoFocus: false,
                  focusNode: null,
                  width: _width * 0.95,
                  height: 290,
                  padding: const EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 5),
                  validateFunction: _validateDescription,
                  onSaveFunction: _saveDescription,
                  //onFieldSubmittedFunction: _node.nextFocus
                ),
                //Add Deals
                ProductSpecificationCustomWidget(
                  specifications: specifications,
                  onUpdateSpecs: (List<String> specs) {
                    specifications = specs;
                  },
                ),
                CustomInputFormField(
                  hintText: "Search Tag 1, Search Tag 2, Search Tag 3",
                  labelText: "Search Tag 1, Search Tag 2, Search Tag 3",
                  //initialValue: _searchTags,
                  prefixIcon: Icons.saved_search,
                  prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
                  textEditingController: searchTagsController,
                  textInputType: TextInputType.text,
                  obscureText: false,
                  textInputAction: TextInputAction.next,
                  minLines: 1,
                  maxLines: 1,
                  width: _width * 0.95,
                  height: 50,
                  padding: const EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 5),
                  autoFocus: false,
                  focusNode: null,
                  //validateFunction:
                  onSaveFunction: _saveSearchTags,
                  //onFieldSubmittedFunction: _node.nextFocus
                ),


                ProductImagesView(99, _copyImageOnModel, productImages),

                buildDealsWidget(model)
              ],
            );
          }),
        ),
      ),
    ));
  }

  displayMessage(BuildContext context, String message) {
    assert(message != null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.lightBlue,
      duration: Duration(milliseconds: 2000),
    ));
  }

  String _validatePrice(String value) {
    if (value.isEmpty) return "Price empty";
    return null;
  }

  void _productNameSave(String value) {
    _productName = value;
  }

  void _productIntlNameSave(String value) {
    _productIntlName = value;
  }

  void _skuSave(String value) {
    _sku = value;
  }

  void _quantitySave(String value) {
    if (value.isNotEmpty) {
      _quantity = int.parse(value);
    } else
      _quantity = 0;
  }

  void _priceSave(String value) {
    if (value.isNotEmpty) {
      _price = double.parse(value);
    } else
      _price = 0;
  }

  void _categorySave(String value) {
    _selectedCategory = value;
  }

  void _brandSave(String value) {
    print("Band Selected $value");
    _selectedBrand = value;
  }

  String _validateBrand(String value) {
    _brandValidationError = null;

    if (_selectedBrand == null) {
      _brandValidationError = "Please select a Brand";
    } else if (_selectedBrand.isEmpty) {
      _brandValidationError = "Please select a Brand";
    }

    return _brandValidationError;
  }

  String _validateCategory(String value) {
    _categoryValidationErrorText = null;
    if (_selectedCategory == null) {
      _categoryValidationErrorText = "Please select a Category";
    } else if (_selectedCategory.isEmpty) {
      _categoryValidationErrorText = "Please select a Category";
    }
    return _categoryValidationErrorText;
  }

  String _validateDescription(String value) {
    if (value.isEmpty) return "Please product product description";
    return null;
  }

  void _saveDescription(String value) {
    _productDescription = value;
  }

  void _saveManufacturerLink(String value) {
    _manufacturerLink = value;
  }

  void _saveSearchTags(String value) {
    _searchTags = value;
    List<String> tags;
    if (_searchTags.length > 0) {
      if (_searchTags.contains(",")) {
        tags = _searchTags.split(",");
      } else {
        tags = [];
        tags.add(_searchTags);
      }
      for (int i = 0; i < tags.length; i++) {
        switch (i) {
          case 0:
            _searchTag1 = tags[i].trim();
            break;
          case 1:
            _searchTag2 = tags[i].trim();
            break;
          case 2:
            _searchTag3 = tags[i].trim();
            break;
        }
      }
    }
  }

  List<DropdownMenuItem<String>> _getCategoriesDropDown(List<Category> categories) {
    List<DropdownMenuItem<String>> items = [];
    items.add(DropdownMenuItem(child: Text(""), value: null));
    if (categories != null) {
      for (var category in categories) {
        items.add(DropdownMenuItem(
          child: Text(category.category),
          value: category.documentPath.path,
        ));
      }
      //_selectedCategory = items[0].value;
    }
    return items;
  }

  Widget buildProductCategoryDropDown() {
    return StreamBuilder<List<Category>>(
        stream: categories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 78, maxWidth: 300),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 5, left: 3, right: 1),
                child: CustomDropDownWidget(
                  key: _formKey,

                  hintText: "Category",
                  errorText: _categoryValidationErrorText,
                  helperText: "Please select Category.",
                  labelText: "Category",
                  prefixIcon: Icons.qr_code_sharp,
                  prefixIconColor: Colors.orange,
                  dropDownValues: _getCategoriesDropDown(snapshot.data),
                  selectedValue: _selectedCategory,
                  validatorFunction: _validateCategory,
                  setValueFunction: _categorySave,
                  onChangeFunction: _categorySave,
                  width: _width * 0.70,
                  height: 70,
                  //focusNode: _intCatCodeFocusNode,
                  enable: true,
                ),
              ),
            ),
          );
        });
  }
  Future<ConfirmAction> _asyncDealSelectionDialog(BuildContext context) async {
    final model = context.read(productViewModelProvider.notifier);
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Deal Type',
            style: k16Black,
          ),
          content: DealsWidget(model: model),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('CONFIRM'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CONFIRM);
              },
            )
          ],
        );
      },
    );
  }

  _onDealAdd() async {
    final model = context.read(productViewModelProvider.notifier);
    Deals _deals = model.deal;
    ConfirmAction confirmAction = await _asyncDealSelectionDialog(context);
    if (confirmAction == ConfirmAction.CANCEL) {
      model.deal = _deals;
    }
    if (model.deal != null && model.deal != _deals) {
      model.dealsAddedDateTime = DateTime.now();
    }
    setState(() {});
  }

  _onDealRemove() {
    final model = context.read(productViewModelProvider.notifier);
    if (model.deal != null) {
      setState(() {
        model.deal = null;
        model.dealsAddedDateTime = null;
      });
    }
  }


  Widget buildDealsWidget(ProductViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: _width * 0.95,
        decoration: _fieldDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    child: Text(
                      "Deals",
                      style: k16Black,
                    )),
                Visibility(
                  visible: model.deal == null,
                  child: AnimatedButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.orangeAccent,
                        size: 30.0,
                      ),
                      onTapAction: _onDealAdd),
                ),
                Visibility(
                  visible: model.deal != null,
                  child: AnimatedButton(
                      icon: Icon(
                        Icons.remove,
                        color: Colors.orangeAccent,
                        size: 30.0,
                      ),
                      onTapAction: _onDealRemove),
                ),
              ],
            ),
            Visibility(
              visible: model.deal != null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                model.deal == null ? Text("") : Text("${model.deal.name} ${model.deal.dealValue}"),
              ),
            ),
          ],
        ),
      ),
    );

  }

  List<DropdownMenuItem<String>> _getBrandsDropDown(List<Brands> brands) {
    List<DropdownMenuItem<String>> items = [];
    items.add(DropdownMenuItem(child: Text(""), value: null));
    if (brands != null) {
      for (var brand in brands) {
        items.add(DropdownMenuItem(
          child: Text(brand.brand),
          value: brand.documentPath.path,
        ));
      }
      //_selectedBrand = items[0].value;
    }
    return items;
  }

  Widget buildProductBrandDropDown() {
    return StreamBuilder<List<Brands>>(
        stream: brands,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 78, maxWidth: 300),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 5, left: 3, right: 1),
                child: CustomDropDownWidget(
                  key: _formKey,
                  hintText: "Brand",
                  errorText: _brandValidationErrorText,
                  helperText: "Please select Brand.",
                  labelText: "Brand",
                  prefixIcon: Icons.qr_code_sharp,
                  prefixIconColor: Colors.orange,
                  dropDownValues: _getBrandsDropDown(snapshot.data),
                  selectedValue: _selectedBrand,
                  validatorFunction: _validateBrand,
                  setValueFunction: _brandSave,
                  onChangeFunction: _brandSave,
                  width: _width * 0.70,
                  height: 70,
                  //focusNode: _intCatCodeFocusNode,
                  enable: true,
                ),
              ),
            ),
          );
        });
  }
}

class ProductSpecificationCustomWidget extends StatefulWidget {

  ProductSpecificationCustomWidget({Key key, this.specifications, this.onUpdateSpecs}) : super(key: key);
  final List<String> specifications;
  final Function onUpdateSpecs;



  @override
  _ProductSpecificationCustomWidgetState createState() => _ProductSpecificationCustomWidgetState();
}

class _ProductSpecificationCustomWidgetState extends State<ProductSpecificationCustomWidget> {
  double _width = 0;
  int noOfSpecs = 6;
  int maxNoOfSpecs = 20;
  List<String> specifications;
  List<TextEditingController> specificationController = [];
  var _scrollController = ScrollController(initialScrollOffset: 0.0);


  @override
  void initState() {
    super.initState();
    specifications = widget.specifications;
    _scrollController.addListener(()  async {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange) {
          
          if (noOfSpecs < maxNoOfSpecs) {
            setState(() {
              noOfSpecs++;
            });
          }
        }
        if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print("reach the top");
        }
      }
    });
  }


  @override
  void didUpdateWidget(ProductSpecificationCustomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.specifications != oldWidget.specifications) {
      specifications = widget.specifications;
      specificationController = [];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _width = MediaQuery.of(context).size.width;
    Icons abc;

    String getSpecLineValue(int index) {
      if (specifications != null && specifications.length > index ) {
        return specifications[index];
      }
      return null;
    }

    return Consumer(
      builder:  ((context, watch, _){
        final model = watch(productViewModelProvider.notifier);
        return Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 12, right: 1),
          child: Container(
            width: _width * 0.95,
            height: 200,
            child: InputDecorator(
              decoration: InputDecoration(
                  border: outlineInputBorder(Colors.grey),
                  enabledBorder: outlineInputBorder(Colors.orangeAccent),
                  focusedBorder: outlineInputBorder(Colors.blue),
                  errorBorder: outlineInputBorder(Colors.red),
                  disabledBorder: outlineInputBorder(Colors.grey),
                  labelText: "Specifications"),

              child: Scrollbar(
                thickness: 6 ,
                radius: Radius.circular(50),
                child: ListView.builder(
                    addAutomaticKeepAlives: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: specifications != null && specifications.length > noOfSpecs ? specifications.length : noOfSpecs,
                    itemBuilder: (context, index) {
                      if (specificationController.length < index + 1) {
                        specificationController.add(TextEditingController());
                        specificationController[index].text = getSpecLineValue(index);
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(padding: EdgeInsets.all(2),
                            child: SizedBox(
                              width: 20,
                                child: Text("${index+1}.")),
                          ),
                          CustomInputFormField(
                            //hintText: "Search Tag 1, Search Tag 2, Search Tag 3",
                            //labelText: "Search Tag 1, Search Tag 2, Search Tag 3",
                            //initialValue: _searchTags,
                            //prefixIcon: Icons.saved_search,
                            //prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
                            //dbValue: getSpecLineValue(model, index),
                            suffixIcon: Icons.clear,
                            suffixIconColor: Colors.grey[500],
                            suffixIconFunction: () {
                              specificationController[index].clear();
                            },
                            suffixIconConstraints: BoxConstraints.tight(Size(20,30)),
                            textEditingController: specificationController[index],
                            textInputType: TextInputType.text,
                            obscureText: false,
                            textInputAction: TextInputAction.next,
                            underLineInputBorder: true,
                            minLines: 1,
                            maxLines: 1,
                            maxLength: 60,
                            width: _width * 0.79,
                            height: 30,
                            padding: const EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 1),
                            autoFocus: false,
                            focusNode: null,
                            //validateFunction:
                            onChangeFunction: (value) {
                              if (specifications != null && specifications.length > index) {
                                specifications[index] = value;
                              }
                              else {
                                specifications.add(value);
                              }
                              widget.onUpdateSpecs(specifications);
                            },
                            //onFieldSubmittedFunction: _node.nextFocus
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ),
        );
      })
    );
  }
}
