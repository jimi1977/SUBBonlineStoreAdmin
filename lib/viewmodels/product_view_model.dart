import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';
import 'package:services/shelf.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/viewmodels/product_image_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_options_view_model.dart';
import 'package:translator/translator.dart';
import 'package:path/path.dart' as Path;

abstract class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final Product product;

  ProductLoaded(this.product);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductLoaded && runtimeType == other.runtimeType && product == other.product;

  @override
  int get hashCode => product.hashCode;
}

class ProductSaving extends ProductState {
  const ProductSaving();
}

class ProductSaved extends ProductState {
  final Product product;

  ProductSaved(this.product);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductSaved && runtimeType == other.runtimeType && product == other.product;

  @override
  int get hashCode => product.hashCode;
}

class ProductError extends ProductState {
  final String errorMessage;

  ProductError(this.errorMessage);
}

final productViewModelProvider = StateNotifierProvider.autoDispose((ref) => ProductViewModel(
      ref.watch(productServiceProvider),
      ref.watch(categoryServiceProvider),
      ref.watch(brandServiceProvider),
      ref.watch(translatorServiceProvider),
      ref.watch(productOptionsViewModelProvider)
    ));

class ProductViewModel extends StateNotifier<ProductState> {

  String errorMessage;

  Product product;


  final ProductService productService;
  final CategoryService categoryService;
  final BrandService  brandService;
  final TranslatorService translatorService;
  final ProductOptionsViewModel productOptionsViewModel;

  ProductViewModel(this.productService, this.categoryService, this.brandService, this.translatorService, this.productOptionsViewModel) : super(ProductInitial());

  String productId;
  List<SizeEnum> _sizes;
  String _selectedBrand;
  String _selectedCategory;
  String _selectedStore;
  String _productName;
  String _productIntlName;
  String _sku;
  int _quantity;
  double _price;
  String _description;
  int _rating;
  int _numberOfUsers;
  String _manufacturerLink;
  String _searchTag1;
  String _searchTag2;
  String _searchTag3;
  List<String> imagesUrl = [];
  List<String> imagesStorageName = [];
  List<ProductImage> productImages = [];
  List<String> retrievedImages = [];

  List<SizeEnum> get sizes => _sizes;

  Deals _deal;
  DateTime _addedDateTime;
  DateTime _dealsAddedDateTime;
  bool _isSaving = false;
  bool _newProduct;

  String _containSizes;
  String _containsColors;
  String _salesTaxApply;
  String _measurementUnit;

  final storage = FirebaseStorage.instance;

  static const folder = 'images';
  String get selectedBrand => _selectedBrand;

  set selectedBrand(String value) {
    _selectedBrand = value;
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

  Stream<List<Category>> getCategoriesStream(){
    var snapshot = categoryService.streamCategories();
    return snapshot.map((event) => event.docs.map((e) => Category.fromFirestore(e)).toList());
  }
  Stream<List<Brands>> getBrandsStream(){
    var snapshot = brandService.streamBrands();
    return snapshot.map((event) => event.docs.map((e) => Brands.fromFireStore(e)).toList());
  }

  rebuildState() {
    state = ProductLoading();
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

  Future<bool> upLoadProductImage(ProductImage productImage, String filePath) async {

    //String _downloadUrl;
    //File imageFile;
    //StorageFileDownloadTask storageFileDownloadTask = storage.ref().child(filePath).writeToFile(imageFile);
    bool ibSave = false;
    UploadTask uploadTask = storage.ref().child(filePath).putFile(productImage.image);
    try {
      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        var _downloadUrl = await snapshot.ref.getDownloadURL();
        productImage.downloadURL = _downloadUrl.toString();
        imagesUrl.add(_downloadUrl.toString());
        imagesStorageName.add(filePath);
        ibSave = true;
      }
    } on FirebaseException  catch (e) {
      ibSave = false;
      if (e.code == 'permission-denied') {
        errorMessage = 'User does not have permission to upload to this reference.';
      }
      else
        errorMessage = e.toString();
    }
    return ibSave;
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
  Future<bool> saveProductImage() async {
    imagesUrl = [];
    imagesStorageName = [];
    bool isSave = true;
    String _filePath;
    int noOfImages = productImages.length;
    for (var productImage in productImages) {
      if (productImage.downloadURL != null) {
        imagesUrl.add(productImage.downloadURL.toString());
        continue;
      }
      int i = 0;
      i++;
      _filePath = productName + '-' + i.toString() + '-' + DateTime.now().toIso8601String().split(".")[0];
      _filePath = '$folder/$_filePath';

      bool imageUploaded = await upLoadProductImage(productImage, _filePath);
      if (imageUploaded == false) {
        errorMessage = "Error in uploading Image";
        isSave = false;
      } else
        isSave = true;
    }
    if (imagesUrl.length != noOfImages) {
      errorMessage = 'All Images are not uploaded ${imagesUrl.length}';
      print(errorMessage);
      isSave = false;
    }
    return isSave;
  }
  Future<bool> saveProductDetails() async {
    bool isSave = false;
    bool imageSaved = await saveProductImage();
    if (!imageSaved) return imageSaved;
    List<String> searchKeywords = indexProductName(_productName);
    List<String> searchTag1 = _searchTag1 != null ? indexProductName(_searchTag1) : null;
    List<String> searchTag2 = _searchTag2 != null ? indexProductName(_searchTag2) : null;
    List<String> searchTag3 = _searchTag3 != null ? indexProductName(_searchTag3) : null;
    if (deal != null && _dealsAddedDateTime == null) {
      _dealsAddedDateTime = DateTime.now();
    }
    print(productOptionsViewModel.toString());

    Product _product = Product(
        productId: productId,
        name: _productName,
        intlName: _productIntlName,
        category: FirebaseFirestore.instance.doc(_selectedCategory),
        brand: FirebaseFirestore.instance.doc(_selectedBrand),
        sku: _sku,
        quantity: _quantity,
        price: _price,
        //unit: _unitsOfMeasurements.toString().split(".")[1],
        description: _description,
        imageUrl: imagesUrl,
        deals: deal,
        addedDateTime: _addedDateTime,
        dealsAddedDateTime: _dealsAddedDateTime,
        searchKeywords: searchKeywords,
        rating: _rating,
        numberOfUsers: _numberOfUsers,
        storeId: _selectedStore,
        searchTag1: searchTag1,
        searchTag2: searchTag2,
        searchTag3: searchTag3);

    isSave = await productService.saveProduct(_product);
    if (!isSave) {
      errorMessage = "Error in saving product information";
    }
    else {
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
    return isSave;
  }

  String unitOfMeasurement;
  setProductionOptions() {
    if (productOptionsViewModel.sizes == "Y"){
      if (productOptionsViewModel.selectedSizes.isNotEmpty && productOptionsViewModel.selectedSizes.length == 1) {
        unitOfMeasurement = productOptionsViewModel.selectedSizes.first;
      } else {

      }
    }
  }

}
