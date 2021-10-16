import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/category.dart';
import 'package:services/category_service.dart';
import 'package:subbonline_storeadmin/models/main_category.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/main_category_service.dart';
import 'package:subbonline_storeadmin/viewmodels/image_upload_view_model.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  CategoryLoaded(this.categories);
}

class CategorySaving extends CategoryState {
  const CategorySaving();
}

class CategorySave extends CategoryState {
  final Category category;

  const CategorySave(this.category);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CategorySave && runtimeType == other.runtimeType && category == other.category;

  @override
  int get hashCode => category.hashCode;
}

class CategoryError extends CategoryState {
  final String errorMessage;

  CategoryError(this.errorMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryError && runtimeType == other.runtimeType && errorMessage == other.errorMessage;

  @override
  int get hashCode => errorMessage.hashCode;
}

final categoryViewModelProvider = StateNotifierProvider<CategoryViewModel, CategoryState>((ref) => CategoryViewModel(
    ref.watch(categoryServiceProvider),
    ref.watch(mainCategoryServiceProvider),
    ref.watch(imageUploadProvider.notifier)));

class CategoryViewModel extends StateNotifier<CategoryState> {
  final CategoryService categoryService;
  final MainCategoryService mainCategoryService;
  final ImageUploadViewModel imageUploadViewModel;

  Category category;

  CategoryViewModel(this.categoryService, this.mainCategoryService, this.imageUploadViewModel)
      : super(CategoryInitial());

  bool isImageChanged() {
    return imageUploadViewModel.isImageChanged();
  }

  bool isImageAvailable() {
    return imageUploadViewModel.isImageAvailable();
  }

  initialise() {
    category = null;
    imageUploadViewModel.initialise();
    rebuildWidget();
  }

  Future<List<Category>> getCategories(String name) async {
    if (name == null || name.length < 1) return null;
    try {
      //state = MainCategoryLoading();
      var categories = await categoryService.getCategoriesByNameWithLimit(name, 5);
      state = CategoryLoaded(categories);
      return categories;
    } on Exception catch (e) {
      state = CategoryError(e.toString());
    }
    return null;
  }

  Future<Category> getCategoryByName(String name) async {
    assert(name != null);
    return await categoryService.getMainCategoryByName(name);
  }

  Future<MainCategory> getMainCategoryById(String id) async {
    assert(id != null);
    return await mainCategoryService.getMainCategoryById(id);
  }

  Future<String> getMainCategoryName(String id) async {
    var mainCategory = await getMainCategoryById(id);
    if (mainCategory != null) {
      return mainCategory.name;
    }
    return null;
  }

  Future<MainCategory> getMainCategoryByName(String name) async {
    assert(name != null);
    return await mainCategoryService.getMainCategoryByName(name);
  }

  Future<List<MainCategory>> getMainCategories(String name) async {
    try {
      var categories = await mainCategoryService.getMainCategoriesByNameWithLimitCached(name, 5);
      return categories;
    } on Exception catch (e) {
      state = CategoryError(e.toString());
    }
    return null;
  }

  populateCategory(Category category) {
    this.category = category;
    imageUploadViewModel.setImageUrl(category.imageUrl);
  }

  Future<void> saveCategory({
    String id,
    String category,
    String mainCategory
  }) async {
    assert(category!=null);
    assert(mainCategory!=null);
    state = CategorySaving();
    try {
      var imageDownloadUrl = await imageUploadViewModel.uploadImage('$category', '/categories/subCategories');
      Category _category = Category(
          id: id,
        category: category,
        mainCategory: mainCategory,
        imageUrl: imageDownloadUrl,
      );
      categoryService.saveCategory(_category);
      state = CategorySave(_category);
    } on Exception catch (e) {
      state = CategoryError(e.toString());
    }
  }

  rebuildWidget() {
    state = CategoryInitial();
  }

}
