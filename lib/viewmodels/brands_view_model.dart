import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';
import 'package:services/brand_service.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/viewmodels/image_upload_view_model.dart';

abstract class BrandsState {
  const BrandsState();
}

class BrandsInitial extends BrandsState {
  const BrandsInitial();
}

class BrandsLoading extends BrandsState {
  const BrandsLoading();
}

class BrandsLoaded extends BrandsState {
  final Brands brands;

  BrandsLoaded(this.brands);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BrandsLoaded && runtimeType == other.runtimeType && brands == other.brands;

  @override
  int get hashCode => brands.hashCode;
}

class BrandSave extends BrandsState {
  final Brands brands;

  BrandSave(this.brands);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BrandSave && runtimeType == other.runtimeType && brands == other.brands;

  @override
  int get hashCode => brands.hashCode;
}

class BrandsError extends BrandsState {
  final String errorMessage;

  BrandsError(this.errorMessage);
}

final brandViewModelProvider =
    StateNotifierProvider((ref) => BrandsViewModel(ref.watch(brandServiceProvider), ref.watch(imageUploadProvider.notifier)));

class BrandsViewModel extends StateNotifier<BrandsState> {
  BrandsViewModel(this.brandService, this.imageUploadViewModel) : super(BrandsInitial());

  final BrandService brandService;
  final ImageUploadViewModel imageUploadViewModel;

  String brandId;
  String brandName;
  String brandDescription;
  String imageUrl;
  DocumentReference documentPath;

  initialise() {
    brandId = null;
    brandName = null;
    brandDescription = null;
    imageUploadViewModel.initialise();
  }

  Future<List<Brands>> getBrandsSearchedList(String brandName, int limit) async {
    try {
      //state = BrandsLoading();
      if (brandName != null && brandName.length < 1) {
        return null;
      }
      final brands =  await brandService.getBrandsForSearchList(brandName, limit);
      //state = BrandsLoaded(brands);
      return brands;
    } on Exception catch (e) {
      state = BrandsError(e.toString());
    }
    return null;
  }

  Future<Brands> getBrandByName(String name) async {
    return await brandService.getBrandByName(name);
  }

  bool isImageChanged() {
    return imageUploadViewModel.isImageChanged();
  }

  populateBrand(String brandId, String name, String description, String imageUrl ) {
    this.brandId = brandId;
    this.brandName = name;
    this.brandDescription = brandDescription;
    this.imageUrl = imageUrl;
    state = BrandsLoaded(Brands(brandId: brandId,  brand: name, description: description, imageUrl: imageUrl));
    imageUploadViewModel.setImageUrl(imageUrl);
  }

  saveBrand(String brandId, String name,String description) async {
    try {
      var imageDownloadUrl = await imageUploadViewModel.uploadImage('$brandName', 'brands');
        Brands brand = Brands(brandId: brandId, brand: name, description: description, imageUrl: imageDownloadUrl);
        await brandService.saveBrand(brand);
    } on Exception catch (e) {
      state = BrandsError(e.toString());
    }

  }

}
