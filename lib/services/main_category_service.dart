



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subbonline_storeadmin/models/main_category.dart';
import 'package:uuid/uuid.dart';

class MainCategoryService {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'mainCategory';

  void createCategory(MainCategory mainCategory){
    var id = Uuid();
    String categoryId = id.v1();

    try {
      _firestore.collection(ref).doc(categoryId).set(mainCategory.toMap(), SetOptions(merge: true));
    } on Exception catch (e) {
      rethrow;
    }
  }



  Future<List<MainCategory>> getMainCategoriesByNameWithLimit(String name, int limit) async {
    assert(limit!=null);
    try {
      QuerySnapshot querySnapShot = await _firestore.collection(ref).
      where('name', isGreaterThanOrEqualTo: name)
          .orderBy('name')
          .limit(limit)
          .get();
      var _mainCategories = querySnapShot.docs.map((snapshot) => MainCategory.fromFireStore(snapshot));
      return _mainCategories.toList();
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<MainCategory> getMainCategoryByName(String name) async {
    try {
      QuerySnapshot querySnapShot = await _firestore.collection(ref).
      where('name', isEqualTo: name)
          .get();
      var _mainCategories = querySnapShot.docs.map((snapshot) => MainCategory.fromFireStore(snapshot));
      if (_mainCategories.isNotEmpty) {
        return _mainCategories.first;
      }
      return null;

    } on Exception catch (e) {

      rethrow;
    }
  }

  saveMainCategory(MainCategory mainCategory) {
    assert(mainCategory!=null);
    if (mainCategory.id == null) {
      createCategory(mainCategory);
    }
    else {
      try {
        _firestore.collection(ref).doc(mainCategory.id).set(mainCategory.toMap(), SetOptions(merge: true));
      } on Exception catch (e) {
        rethrow;
      }
    }
  }




}