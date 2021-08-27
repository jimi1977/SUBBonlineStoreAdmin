import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subbonline_storeadmin/enums/order_satges_enum.dart';
import 'package:subbonline_storeadmin/models/order.dart';

class OrderService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String ref = "orders";

  bool _orderCreated = true;

  String errorMessage;

  Stream<QuerySnapshot> getOrdersStreamByUser(String uid, int limit) {
    return _firestore.collection(ref).where('uid', isEqualTo: uid).limit(limit).snapshots();
  }

  Stream<QuerySnapshot> getOrdersByStoreNew(String storeId) {
    return _firestore
        .collection(ref)
        .where("stores", arrayContains: storeId)
        .where("orderDeliveryDateTimeGMT", isNull: true)
        .orderBy("orderDateTime", descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> getOrderStreamByOrderId(String orderId) {
    return _firestore.collection(ref).doc(orderId).snapshots();
  }

  Stream<DocumentSnapshot> getStoreOrdersOfStore(String orderId, String storeId, String branchId) {
    return _firestore.collection(ref).doc(orderId).collection("storeOrders").doc(storeId).snapshots();
  }

  Stream<QuerySnapshot> getStoreOrdersSubCollectionStream(String uid, String orderId) {
    return _firestore.collection(ref).doc(orderId).collection('storeOrders').snapshots();
  }

  Stream<QuerySnapshot> getStoreOrdersByStoreIdAndStatus(String storeId, String branchId, String status) {
    try {
      // return _firestore.collection("storeOrders")
      //     .where("storeId", isEqualTo:storeId )
      //     .where("branchId", isEqualTo:  branchId)
      //     .where("status", isEqualTo: status)
      //     .orderBy("orderDateTime", descending: true).snapshots();

      return _firestore
          .collection('storeOrders')
          .where("storeId", isEqualTo: storeId)
          .where("branchId", isEqualTo: branchId)
          .where("status", isEqualTo: status)
          .orderBy("orderDateTime", descending: true)
          .snapshots();
    } on Exception catch (e) {
      print("EXCEPTION ${e.toString()}");
    }
  }

  Stream<QuerySnapshot> getStoreOrdersByStoreIdAndStatuses(String storeId, String branchId, List<String> statuses) {
    try {
      return _firestore
          .collection('storeOrders')
          .where("storeId", isEqualTo: storeId)
          .where("branchId", isEqualTo: branchId)
          .where("status", whereIn: statuses)
          .orderBy("orderDateTime", descending: false)
          .snapshots();
    } on Exception catch (e) {
      print("EXCEPTION ${e.toString()}");
    }
  }

  Stream<QuerySnapshot> getStoreOrdersByStatusesWithLimit(
      String storeId, String branchId, List<String> statuses, int limit) {
    try {
      return _firestore
          .collection('storeOrders')
          .where("storeId", isEqualTo: storeId)
          .where("branchId", isEqualTo: branchId)
          .where("status", whereIn: statuses)
          .orderBy("orderDateTime", descending: true)
          .limit(limit)
          .snapshots();
    } on Exception catch (e) {
      print("EXCEPTION ${e.toString()}");
    }
  }

  Stream<QuerySnapshot> getStoreOrdersByStatusesWithDateAndLimit(
      String storeId, String branchId, List<String> statuses, DateTime orderDate, int limit) {
    DateTime startDate = DateTime(orderDate.year, orderDate.month, orderDate.day);
    DateTime endDate = DateTime(orderDate.year, orderDate.month, orderDate.day, 24, 0, 0);
    try {
      return _firestore
          .collection('storeOrders')
          .where("storeId", isEqualTo: storeId)
          .where("branchId", isEqualTo: branchId)
          .where("status", whereIn: statuses)
          .where("orderDateTime", isGreaterThanOrEqualTo: startDate)
          .where("orderDateTime", isLessThanOrEqualTo: endDate)
          .orderBy("orderDateTime", descending: true)
          .limit(limit)
          .snapshots();
    } on Exception catch (e) {
      print("EXCEPTION ${e.toString()}");
    }
  }

  Future<Order> getOrderById(String orderId) async {
    var order = await _firestore.collection(ref).doc(orderId).get();
    return Order.fromMap(order.data());
  }

  Future<List<StoreOrder>> getStoreOrders(String orderId) async {
    var storeOrders = await _firestore.collection(ref).doc(orderId).collection('storeOrders').get();
    return storeOrders.docs.map((doc) => StoreOrder.fromMap(doc.data())).toList();
  }

  updateOrderStage(Order order, OrderStageEnum orderStage) async {
    DateTime _currentDatetime = DateTime.now();

    List<OrderStage> orderStages = order.storeOrders.orderStage;

    OrderStage _orderStage =
        OrderStage(stage: orderStage.toString().split(".")[1], stageChangeDatetime: _currentDatetime);

    orderStages.add(_orderStage);

    try {
      await _firestore
          .collection("storeOrders")
          .doc(order.storeOrders.orderId + "-" + order.storeOrders.storeId)
          .update({"orderStage": fireStoreOrderStages(orderStages), "status": orderStage.toString().split(".")[1]});

      // await _firestore
      //     .collection(ref)
      //     .doc(order.orderId)
      //     .collection("storeOrders")
      //     .doc(order.storeOrders.storeId)
      //     .update({"orderStage": fireStoreOrderStages(orderStages),
      //      "status":orderStage.toString().split(".")[1]});
    } on Exception catch (e) {
      errorMessage = e.toString();
    }
  }

  cancelOrder(
      Order order, OrderCancelledEnum cancelStatus, String cancellationReasonCode, String cancellationReason) async {
    DateTime _currentDatetime = DateTime.now();

    List<OrderStage> orderStages = order.storeOrders.orderStage;

    OrderStage _orderStage =
        OrderStage(stage: cancelStatus.toString().split(".")[1], stageChangeDatetime: _currentDatetime);

    orderStages.add(_orderStage);
    try {
      await _firestore
          .collection("storeOrders")
          .doc(order.storeOrders.orderId + "-" + order.storeOrders.storeId)
          .update({
        "orderStage": fireStoreOrderStages(orderStages),
        "status": cancelStatus.toString().split(".")[1],
        "cancellationReasonCode": cancellationReasonCode,
        "cancellationReason": cancellationReason
      });

      // await _firestore
      //     .collection(ref)
      //     .doc(order.orderId)
      //     .collection("storeOrders")
      //     .doc(order.storeOrders.storeId)
      //     .update({"orderStage": fireStoreOrderStages(orderStages),
      //      "status":orderStage.toString().split(".")[1]});
    } on Exception catch (e) {
      errorMessage = e.toString();
    }
  }

  List<Map<String, dynamic>> fireStoreOrderStages(List<OrderStage> orderStages) {
    List<Map<String, dynamic>> convertedOrderStages = [];
    orderStages.forEach((orderStage) {
      OrderStage _orderStage = orderStage;
      convertedOrderStages.add(_orderStage.toMap());
    });
    return convertedOrderStages;
  }
}
