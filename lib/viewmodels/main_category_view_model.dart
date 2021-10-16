import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/models/main_category.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/main_category_service.dart';
import 'package:subbonline_storeadmin/viewmodels/image_upload_view_model.dart';

abstract class MainCategoryState {
  const MainCategoryState();
}

class MainCategoryInitial extends MainCategoryState {
  const MainCategoryInitial();
}

class MainCategoryLoading extends MainCategoryState {
  const MainCategoryLoading();
}

class MainCategoryRebuild extends MainCategoryState {
  const MainCategoryRebuild();
}

class MainCategoryLoaded extends MainCategoryState {
  final List<MainCategory> mainCategory;

  const MainCategoryLoaded(this.mainCategory);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainCategoryLoaded && runtimeType == other.runtimeType && mainCategory == other.mainCategory;

  @override
  int get hashCode => mainCategory.hashCode;
}

class MainCategorySaving extends MainCategoryState {
  const MainCategorySaving();
}

class MainCategorySave extends MainCategoryState {
  final MainCategory mainCategory;

  MainCategorySave(this.mainCategory);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainCategorySave && runtimeType == other.runtimeType && mainCategory == other.mainCategory;

  @override
  int get hashCode => mainCategory.hashCode;
}

class MainCategoryError extends MainCategoryState {
  final String errorMessage;

  const MainCategoryError(this.errorMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainCategoryError && runtimeType == other.runtimeType && errorMessage == other.errorMessage;

  @override
  int get hashCode => errorMessage.hashCode;
}

final mainCategoryViewModelProvider = StateNotifierProvider<MainCategoryViewModel, MainCategoryState>(
    (ref) => MainCategoryViewModel(ref.watch(mainCategoryServiceProvider), ref.watch(imageUploadProvider.notifier)));

class MainCategoryViewModel extends StateNotifier<MainCategoryState> {
  MainCategoryViewModel(this.mainCategoryService, this.imageUploadViewModel) : super(MainCategoryInitial());

  final MainCategoryService mainCategoryService;
  final ImageUploadViewModel imageUploadViewModel;

  MainCategory mainCategory;

  initialise() {
    mainCategory = null;
    imageUploadViewModel.initialise();
    rebuildWidget();
  }

  bool isImageChanged() {
    return imageUploadViewModel.isImageChanged();
  }

  bool isImageAvailable() {
    return imageUploadViewModel.isImageAvailable();
  }

  Future<List<MainCategory>> getMainCategories(String name) async {
    if (name == null || name.length < 1) return null;
    try {
      //state = MainCategoryLoading();
      var categories = await mainCategoryService.getMainCategoriesByNameWithLimit(name, 5);
      state = MainCategoryLoaded(categories);
      return categories;
    } on Exception catch (e) {
      state = MainCategoryError(e.toString());
    }
    return null;
  }

  Future<MainCategory> getMainCategory(String name) async {
    assert(name != null);
    return await mainCategoryService.getMainCategoryByName(name);
  }

  populateMainCategory(MainCategory mainCategory) {
    this.mainCategory = mainCategory;
    imageUploadViewModel.setImageUrl(mainCategory.imageUrl);
  }

  rebuildWidget() {
    state = MainCategoryRebuild();
  }

  Future<void> saveMainCategory({
    String id,
    String name,
    String type,
    String advertise,
    String advertText,
    String textColor,
    int displaySequence,
  }) async {
    state = MainCategorySaving();

    if (!isImageAvailable() && advertise == 'Y') {
      print("Image is not available");
      // state = MainCategoryError("Image should be provided when Advertise on App Banner flag is ticked.");
      throw Exception("Image should be provided when Advertise on App Banner flag is ticked.");
    }
    if (advertText != null && advertText.length > 0 && textColor == null) {
      throw Exception("Please select Advertising Text Color.");
    }
    try {
      var imageDownloadUrl = await imageUploadViewModel.uploadImage('$name', 'categories');
      MainCategory _mainCategory = MainCategory(
          id: id,
          name: name,
          type: type,
          imageUrl: imageDownloadUrl,
          advertise: advertise,
          advertText: advertText,
          textColor: textColor,
          displaySequence: displaySequence
      );

      mainCategoryService.saveMainCategory(_mainCategory);
      state = MainCategorySave(_mainCategory);
    } on Exception catch (e) {
      state = MainCategoryError(e.toString());
    }
  }
}
