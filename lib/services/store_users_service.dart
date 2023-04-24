import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subbonline_storeadmin/models/rider_quque.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:uuid/uuid.dart';

class StoreUserService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String errorMessage;

  String ref = 'storeUsers';
  String riderQref = 'riderQueue';

  Future<StoreUsers> getStoreUser(String storeId, String branchId, String userId) async {
    print("Branch Id: ${branchId.trim()}");
    var storeDocument = await _firestore
        .collection(ref)
        .where("storeId", isEqualTo: storeId)
        .where("branchId", isEqualTo: branchId)
        .where("userId", isEqualTo: userId)
        .get();
    if (storeDocument.size > 0) {
      var storeUsers = StoreUsers.fromMap(storeDocument.docs.last.data());
      return storeUsers;
    }
    return null;
  }

  Future<StoreUsers> verifyStoreUserPassword(String storeId, String branchId, String userId, String password) async {
    var storeUsers = await getStoreUser(storeId, branchId, userId);

    if (storeUsers != null && storeUsers.password == password) {
      return storeUsers;
    }
    return null;
  }

  Future<StoreUsers> checkIfUserExists(String storeId, String branchId, String userId) async {
    var storeUsers = await getStoreUser(storeId, branchId, userId);
    return storeUsers;
  }

  Future<List<StoreUsers>> getStoreUsers(String storeId, String branchId) async {
    var storeUserDocs = await _firestore
        .collection(ref)
        .where("storeId", isEqualTo: storeId)
        .where("branchId", isEqualTo: branchId)
        .get();
    var storeUsers = storeUserDocs.docs.map((snapshot) => StoreUsers.fromMap(snapshot.data()));
    return storeUsers.toList();
  }

  Future<List<StoreUsers>> getBranchRiders(String storeId, String branchId) async {
    var storeUserDocs = await _firestore
        .collection(ref)
        .where("storeId", isEqualTo: storeId)
        .where("branchId", isEqualTo: branchId)
        .where("roleCode", isEqualTo: 1)
        .where("status", isEqualTo: "A")
        .get();
    var storeUsers = storeUserDocs.docs.map((snapshot) => StoreUsers.fromMap(snapshot.data()));
    return storeUsers.toList();

  }

  Future<void> createNewUser(StoreUsers storeUser) async {
    try {
      await _firestore.collection(ref).doc(storeUser.uid).set(storeUser.toMap(), SetOptions(merge: true));
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> updateUser(StoreUsers storeUsers) async {
    try {
      await _firestore.collection(ref).doc(storeUsers.uid).set(storeUsers.toMap(), SetOptions(merge: true));
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  inActivateUser(String uid, DateTime dateInActivate) async {
    try {
      await _firestore.collection(ref).doc(uid).update({"status": "I", "dateInactivated": dateInActivate});
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  resetPassword(String uid, String newPassword) async {
    try {
      await _firestore.collection(ref).doc(uid).update({"password": newPassword});
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  addRiderQueue(String riderId) async {
    try {

      await _firestore.collection(ref).doc(riderId).update({"ordersInQueue": FieldValue.increment(1)});
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }
  addOrderToRiderQueue(RiderQueue riderQueue) async {
    try {
      var id = Uuid();
      String docId = id.v1();
      await _firestore.collection(riderQref).doc(docId).set(riderQueue.toMap(),SetOptions(merge: true));
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }


  }
  subtractRiderQueue(String riderId) async {
    try {
      await _firestore.collection(ref).doc(riderId).update({"ordersInQueue": FieldValue.increment(1)});
    } on Exception catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }


}
