


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subbonline_storeadmin/models/store.dart';

class StoreService {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String errorMessage;

  String ref = 'stores';

  Future<Store> getStore(String storeId) async {
    var storeDocument = await _firestore.collection(ref).doc(storeId).get();

    var store = Store.fromFireStore(storeDocument);
    return store;
  }

  Future<StoreBranch> getStoreBranch(String storeId, String branchCode) async {
    var snapshot = await _firestore.collection(ref).doc(storeId).collection("branches").where("branchId", isEqualTo:branchCode).get();
    var branchDocument = snapshot.docs.map((e) => e.data());

    var storeBranch = branchDocument.isEmpty? null : StoreBranch.fromMap(branchDocument.last);
    return storeBranch;
  }

  Future<List<Store>> getAllActiveStores() async {
    var snapShot = await _firestore
                  .collection(ref)
                  .where("status", isEqualTo:"A")
                  .get();

    var stores = snapShot.docs.map((snapshot) => Store.fromMap(snapshot.data()));
    return stores.toList();
  }

  Future<List<StoreBranch>> getAllActiveStoreBranches(String storeId) async {
    var snapshots = await _firestore
                  .collection(ref)
                  .doc(storeId)
                  .collection("branches").get();
    //.where("status", isEqualTo:"A")

    var storeBranches = snapshots.docs.map((snapshot) => StoreBranch.fromMap(snapshot.data()));
    return storeBranches.toList();

  }

  saveStore(Store store) async {
    try {
      await _firestore
      .collection(ref)
          .doc(store.storeCode)
          .set(store.toMap(),SetOptions(merge: true));
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }


  }



}