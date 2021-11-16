import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';
import 'package:path/path.dart' as Path;
import 'package:services/shelf.dart';
import 'package:subbonline_storeadmin/enums/viewstate.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/measurement_units_service.dart';
import 'package:subbonline_storeadmin/services/product_color_service.dart';
import 'package:subbonline_storeadmin/viewmodels/product_image_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_options_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_variant_images_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_variant_viewmodel.dart';
import 'package:translator/translator.dart';

final productViewModelProvider = ChangeNotifierProvider((ref) => ProductViewModel(
      ref.watch(productServiceProvider),
      ref.watch(categoryServiceProvider),
      ref.watch(brandServiceProvider),
      ref.watch(translatorServiceProvider),
      ref.watch(productOptionsViewModelProvider),
      ref.watch(productVariantViewModelProvider),
      ref.watch(productVariantImagesViewModelProvider),
      ref.watch(dealsServiceProvider)
    ));

class ProductViewModel with ChangeNotifier {
  final MeasurementUnitsService _measurementUnitsService = MeasurementUnitsService();

  String errorMessage;

  Product product;

  final ProductService productService;
  final CategoryService categoryService;
  final BrandService brandService;
  final TranslatorService translatorService;
  final ProductOptionsViewModel productOptionsViewModel;
  final ProductVariantViewModel productVariantViewModel;
  final ProductVariantImagesViewModel productVariantImagesViewModel;
  final DealsService dealsService;

  ProductViewModel(this.productService, this.categoryService, this.brandService, this.translatorService,
      this.productOptionsViewModel, this.productVariantViewModel, this.productVariantImagesViewModel, this.dealsService);

  String productId;
  String _selectedBrand;
  String _selectedCategory;
  String _selectedStore;
  String _productName;
  String _productIntlName;
  String _sku;
  int _quantity;
  double _price;
  double _oldPrice;
  String _description;
  int _rating;
  int _numberOfUsers;
  String _manufacturerLink;
  String _searchTag1;
  String _searchTag2;
  String _searchTag3;
  List<String> imagesUrl = [];
  List<String> specifications = [];
  List<ProductImage> productImages = [];
  List<String> retrievedImages = [];
  DateTime _addedDateTime;
  DateTime _dealsAddedDateTime;

  Deals _deal;

  final storage = FirebaseStorage.instance;

  final ProductColorService productColorService = ProductColorService();

  static const folder = 'images';

  String get selectedBrand => _selectedBrand;

  set selectedBrand(String value) {
    _selectedBrand = value;
  }

  void initialise() {
    productId = null;
    _selectedBrand = null;
    _selectedCategory = null;
    _selectedStore = null;
    _productName = null;
    _productIntlName = null;
    _sku = null;
    _quantity = null;
    _price = null;
    _oldPrice = null;
    _description = null;
    _rating = null;
    _numberOfUsers = null;
    _manufacturerLink = null;
    _searchTag1 = null;
    _searchTag2 = null;
    _searchTag3 = null;
    _addedDateTime = null;
    _dealsAddedDateTime = null;
    specifications = [];
    productOptionsViewModel.initialise();
    productVariantViewModel.initialise();
  }

  populatedProviders() {
    if (product != null) {
      productOptionsViewModel.sizes = product.containSizes;
      productOptionsViewModel.colors = product.containColors;
      productOptionsViewModel.salesTax = product.salesTaxApplicable;
      productOptionsViewModel.maintainInventory = product.maintainInventory;
      productOptionsViewModel.accessory = product.accessory;
      productOptionsViewModel.retrievedVariants = product.productVariants;
      productVariantViewModel.variants = product.productVariants;
      productVariantViewModel.variantsToSave = product.productVariants;
      productVariantImagesViewModel.setRetrievedImages(product.productVariants);
      productVariantViewModel.errorMessage = "Variants Updated";
      if (product.productVariants != null) {
        product.productVariants.forEach((variant) {
          productOptionsViewModel.productVariantId.add(variant.productVariantId);
          productOptionsViewModel.selectedUnit = _measurementUnitsService.getMeasurementUnitOfSize(variant.size).code;
          productOptionsViewModel.selectedSizes.add(variant.size);
          productOptionsViewModel.selectedUnits.add(variant.size);
          productOptionsViewModel.selectedColors.add(variant.color);
          productOptionsViewModel.selectedUnitValue.add(variant.unitValue.toString());
          productOptionsViewModel.price.add(variant.price.toString());
          productOptionsViewModel.surcharge.add(variant.surcharge.toString());
          productOptionsViewModel.quantity.add(variant.quantity.toString());
          productOptionsViewModel.imageUrl.add(variant.imageUrl);
          if (variant.baseProduct == "Y") {
            productOptionsViewModel.baseProductVariantId = variant.productVariantId;
          }

        });
        productOptionsViewModel.selectedSizes = productOptionsViewModel.selectedSizes.toSet().toList();
        //productOptionsViewModel.selectedUnits = productOptionsViewModel.selectedUnits.toSet().toList();
        //productVariantViewModel.rebuildVariants();
        //productOptionsViewModel.setState(ViewState.Busy);
        //productVariantViewModel.setState(ViewState.Busy);
      }
    }
  }

  Future<List<Deals>> getDeals() {
    return dealsService.getDeals();
  }
  Future<List<Product>> getProductsForSearchList(String productSearchStr) async {
    return await productService.getProductsForSearchList(productSearchStr.toLowerCase(), 10);
  }

  Future<Product> retrieveProductByName(String productName) async {
    assert(productName != null);
    return await productService.retrieveProduct(productName);
  }

  Future<Translation> translateString(String stringToTranslate) async {
    var translation = await translatorService.translateString(stringToTranslate);
    return translation;
  }

  Stream<List<Category>> getCategoriesStream() {
    var snapshot = categoryService.streamCategories();
    return snapshot.map((event) => event.docs.map((e) => Category.fromFirestore(e)).toList());
  }

  Stream<List<Brands>> getBrandsStream() {
    var snapshot = brandService.streamBrands();
    return snapshot.map((event) => event.docs.map((e) => Brands.fromFireStore(e)).toList());
  }

  rebuildState() {
    notifyListeners();
  }

  String get selectedCategory => _selectedCategory;

  set selectedCategory(String value) {
    _selectedCategory = value;
  }

  String get selectedStore => _selectedStore;

  set selectedStore(String value) {
    _selectedStore = value;
  }

  String get productName => _productName;

  set productName(String value) {
    _productName = value;
  }

  String get productIntlName => _productIntlName;

  set productIntlName(String value) {
    _productIntlName = value;
  }

  String get sku => _sku;

  set sku(String value) {
    _sku = value;
  }

  int get quantity => _quantity;

  set quantity(int value) {
    _quantity = value;
  }

  double get price => _price;

  set price(double value) {
    _price = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  int get rating => _rating;

  set rating(int value) {
    _rating = value;
  }

  String get manufacturerLink => _manufacturerLink;

  set manufacturerLink(String value) {
    _manufacturerLink = value;
  }

  String get searchTag1 => _searchTag1;

  set searchTag1(String value) {
    _searchTag1 = value;
  }

  String get searchTag2 => _searchTag2;

  set searchTag2(String value) {
    _searchTag2 = value;
  }

  String get searchTag3 => _searchTag3;

  set searchTag3(String value) {
    _searchTag3 = value;
  }

  Deals get deal => _deal;

  set deal(Deals value) {
    _deal = value;
  }

  DateTime get addedDateTime => _addedDateTime;

  set addedDateTime(DateTime value) {
    _addedDateTime = value;
  }

  DateTime get dealsAddedDateTime => _dealsAddedDateTime;

  set dealsAddedDateTime(DateTime value) {
    _dealsAddedDateTime = value;
  }

  Future<String> upLoadProductImage(ProductImage productImage, String filePath) async {
    //String _downloadUrl;
    //File imageFile;
    //StorageFileDownloadTask storageFileDownloadTask = storage.ref().child(filePath).writeToFile(imageFile);
    bool ibSave = false;
    String _imageUrl;
    UploadTask uploadTask = storage.ref().child(filePath).putFile(productImage.image);
    try {
      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        var _downloadUrl = await snapshot.ref.getDownloadURL();
        productImage.downloadURL = _downloadUrl.toString();
        _imageUrl = _downloadUrl.toString();
        //imagesStorageName.add(filePath);
        ibSave = true;
      }
    } on FirebaseException catch (e) {
      ibSave = false;
      if (e.code == 'permission-denied') {
        errorMessage = 'User does not have permission to upload to this reference.';
      } else
        errorMessage = e.toString();
    }
    return _imageUrl;
  }

  Future<bool> deleteImage(String imageFileName) async {
    bool deleteStatus = false;
    Reference storageReference = storage.ref().child(imageFileName);

    await storageReference
        .delete()
        .then((value) => deleteStatus = true)
        .catchError((onError) => errorMessage = onError.toString());
    return deleteStatus;
  }

  String getImageNameFromURL(String imageUrl) {
    var fileUrl = Uri.decodeFull(Path.basename(imageUrl)).replaceAll(new RegExp(r'(\?alt).*'), '');
    return fileUrl;
  }

  List<String> indexProductName(String productName) {
    int len = productName.length;
    List<String> indexedName = List<String>();
    for (int i = 1; i <= len; i++) {
      indexedName.add(productName.substring(0, i).toLowerCase());
    }
    return indexedName;
  }

  String prepareVariantImageName(ProductVariants variant) {
    String _imageName;
    _imageName = _selectedStore + '-' + productName;
    if (variant.unitValue != null) {
      _imageName = _imageName + '-' + variant.unitValue.toString();
    }
    if (variant.size != null) {
      _imageName = _imageName + productName + '-' + variant.size;
    }
    if (variant.color != null) {
      var _colorName = productColorService.getColorName(variant.color);
      _imageName = _imageName + '-' + _colorName ?? '';
    }
    return _imageName;
  }

  Future<bool> saveProductVariantsImages() async {
    var productVariants = getProductVariants();
    String _filePath;
    bool isSave = true;
    int i = 0;
    List<String> _variantImages;
    int idx = -1;
    int noOfImages = 0;
    for (var variant in productVariants) {
      idx++;
      _variantImages = [];
      List<ProductImage> variantImages = productVariantImagesViewModel.getVariantImages(variant.productVariantId);
      if (variantImages == null) {
        continue;
      }
      for (var variantImage in variantImages) {
        if (variantImage.downloadURL != null) {
          _variantImages.add(variantImage.downloadURL);
          continue;
        }
        i++;
        _filePath = prepareVariantImageName(variant) +
            '-' +
            i.toString() +
            '-' +
            DateTime.now().toIso8601String().split(".")[0];
        _filePath = '$folder/$_filePath';
        isSave = true;
        try {
          String _imageUrl = await upLoadProductImage(variantImage, _filePath);
          if (_imageUrl.isNotEmpty) {
            _variantImages.add(_imageUrl);
          }
        } on Exception catch (e) {
          errorMessage = "Error in uploading Image ${e.toString()}";
          isSave = false;
        }
      }
      productVariants[idx] = setProductVariantImages(productVariants[idx], _variantImages);
    }
    productVariantViewModel.variantsToSave = productVariants;
    return isSave;
  }

  Future<bool> saveProductImage() async {
    imagesUrl = [];
    bool isSave = true;
    String _filePath;
    int noOfImages = productImages.length;
    int i = 0;
    for (var productImage in productImages) {
      if (productImage.downloadURL != null) {
        imagesUrl.add(productImage.downloadURL.toString());
        continue;
      }
      i++;
      _filePath = _selectedStore +
          '-' +
          productName +
          '-' +
          i.toString() +
          '-' +
          DateTime.now().toIso8601String().split(".")[0];
      _filePath = '$folder/$_filePath';
      isSave = true;
      try {
        String _imagesUrl = await upLoadProductImage(productImage, _filePath);
        imagesUrl.add(_imagesUrl);
      } on Exception catch (e) {
        errorMessage = "Error in uploading Image ${e.toString()}";
        isSave = false;
      }
    }
    if (imagesUrl.length != noOfImages) {
      errorMessage = 'All Images are not uploaded ${imagesUrl.length}';
      print(errorMessage);
      isSave = false;
    }
    return isSave;
  }

  List<ProductVariants> getProductVariants() {
    if (productVariantViewModel.variantsToSave == null || productVariantViewModel.variantsToSave.length == 0) {
      return null;
    }
    return productVariantViewModel.variantsToSave;
  }

  ProductVariants setProductVariantImages(ProductVariants productVariants, List<String> imageUrls) {
    return ProductVariants.copyWith(productVariants, imageUrls);
  }

  String getProductUnit() {
    if (productOptionsViewModel.selectedSizes != null && productOptionsViewModel.selectedSizes.length == 1) {
      return productOptionsViewModel.selectedSizes[0];
    }
    if (productOptionsViewModel.selectedSizes == null) {
      return "each";
    }
    return null;
  }

  Future<bool> saveProductDetails() async {
    bool isSave = false;
    bool imageSaved = await saveProductImage();
    if (!imageSaved) return imageSaved;
    imageSaved = await saveProductVariantsImages();
    if (!imageSaved) return imageSaved;
    List<String> searchKeywords = indexProductName(_productName);
    List<String> searchTag1 = _searchTag1 != null ? indexProductName(_searchTag1) : null;
    List<String> searchTag2 = _searchTag2 != null ? indexProductName(_searchTag2) : null;
    List<String> searchTag3 = _searchTag3 != null ? indexProductName(_searchTag3) : null;
    if (deal != null && _dealsAddedDateTime == null) {
      _dealsAddedDateTime = DateTime.now();
    }

    if (product != null && product.price != _price) {
      _oldPrice = product.price;
    }
    else _oldPrice = 0.0;

    Product _product = Product(
        productId: productId,
        name: _productName,
        intlName: _productIntlName,
        category: FirebaseFirestore.instance.doc(_selectedCategory),
        brand: FirebaseFirestore.instance.doc(_selectedBrand),
        sku: _sku,
        quantity: _quantity,
        price: _price,
        oldPrice: _oldPrice,
        containSizes: productOptionsViewModel.sizes,
        containColors: productOptionsViewModel.colors,
        accessory: productOptionsViewModel.accessory,
        salesTaxApplicable: productOptionsViewModel.salesTax,
        unit: getProductVariants() == null ? getProductUnit() : null,
        productVariants: getProductVariants(),
        description: _description,
        imageUrl: imagesUrl,
        deals: deal,
        addedDateTime: _addedDateTime,
        dealsAddedDateTime: _dealsAddedDateTime,
        searchKeywords: searchKeywords,
        rating: _rating,
        numberOfUsers: _numberOfUsers,
        storeId: _selectedStore,
        specifications: specifications != null && specifications.length > 0 ? specifications : null,
        searchTag1: searchTag1,
        searchTag2: searchTag2,
        searchTag3: searchTag3);

    if (_product == product) {
      errorMessage = "There is no change to save";
      return false;
    }
    isSave = await productService.saveProduct(_product);
    if (!isSave) {
      errorMessage = "Error in saving product information";
      return false;
    } else {
      productId = productService.newProductId;
    }
    if (retrievedImages.length > 0) {
      for (var retrievedImage in retrievedImages) {
        if (!imagesUrl.contains(retrievedImage)) {
          String imageName = getImageNameFromURL(retrievedImage);
          bool imageDeleted = await deleteImage(imageName);
          if (imageDeleted = false) {
            errorMessage = "Error in deleting image from Storage";
            isSave = false;
          }
        }
      }
    }
    isSave = await deleteRemovedImages();
    return isSave;
  }

  Future<bool> deleteRemovedImages() async {
    bool isSave = true;
    if (productVariantImagesViewModel.retrievedImages != null && productVariantImagesViewModel.retrievedImages.length > 0) {
      var _variants = getProductVariants();
      if (_variants != null && _variants.length > 0) {
        for (var _variant in _variants) {
          if (_variant.imageUrl != null) {
            _variant.imageUrl.forEach((url) {
              productVariantImagesViewModel.retrievedImages.removeWhere((element) => element.downloadURL == url);
            });
          }
        }
      }
      if (productVariantImagesViewModel.retrievedImages.length > 0) {
        for (var imageToDelete in productVariantImagesViewModel.retrievedImages) {
          String _imageName = getImageNameFromURL(imageToDelete.downloadURL);
          bool imageDeleted = await deleteImage(_imageName);
          if (imageDeleted = false) {
            errorMessage = "Error in deleting image from Storage";
            isSave = false;
          }
        }
      }
    }
    return isSave;
  }

  bool validateProductVariants() {
    if (productOptionsViewModel.sizes != "Y" && productOptionsViewModel.colors != "Y") {
      return true;
    }
    var variants = productVariantViewModel.prepareVariants();
    if (variants == null || variants.length == 0 ) {
      return true;
    }

    variants.forEach((variant) {
      if ((variant.price == null || variant.price <= 0.00) && (variant.surcharge == null || variant.surcharge <= 0.00)) {
        return false;
      }
    });


    return true;
  }
  bool validateProductImages() {
    int idx = 0;
    bool imageExists = false;
    if (productImages != null && productImages.length > 0) {
      return true;
    }
    var productVariants = getProductVariants();
    
    if (productVariants != null) {
      for (var variant in productVariants) {
        idx++;
        List<ProductImage> variantImages = productVariantImagesViewModel.getVariantImages(variant.productVariantId);
        if (variantImages == null) {
          continue;
        }
        imageExists = true;
      }
    }

    return imageExists;

  }

}
