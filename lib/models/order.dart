import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subbonline_storeadmin/models/delivery_address.dart';
import 'package:subbonline_storeadmin/models/payment.dart';
import 'package:subbonline_storeadmin/utility/utility_functions.dart';

class Order {
  final String uid;
  final String orderId;
  final DateTime orderDateTime;
  final double orderPrice;
  final Payment payment;
  final DeliveryAddress deliveryAddress;
  final DateTime orderDeliveryDateTimeGMT;
  final List<String> stores;

//  final List<OrderDetail> orderDetail;
  //final List<OrderStage> orderStage;
  StoreOrder storeOrders;

  Order(
      {this.uid,
      this.orderId,
      this.orderDateTime,
      this.orderPrice,
      this.payment,
      this.deliveryAddress,
      this.orderDeliveryDateTimeGMT,
      this.stores});

  factory Order.fromMap(Map<String, dynamic> map) {
    return new Order(
      uid: map['uid'] as String,
      orderId: map['orderId'] as String,
      orderDateTime: convertTimeStampToDatetime(map['orderDateTime']),
      orderPrice: map['orderPrice'] as double,
      payment: Payment.fromMap(map['payment']),
      deliveryAddress: DeliveryAddress.fromMap(map['deliveryAddress']),
      orderDeliveryDateTimeGMT: convertTimeStampToDatetimeWithNull(map['orderDeliveryDateTimeGMT']),
      stores: List.from(map['stores']),

      //orderStage: List.from(map['orderStage']).map((e) => OrderStage.fromMap(e)).toList(),
      //riderId: map['riderId'] as String,
      //storeId: map['storeId'] as String,
      //storeName: map['storeName'] as String
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'uid': this.uid,
      'orderId': this.orderId,
      'orderDateTime': this.orderDateTime,
      'orderPrice': this.orderPrice,
      'payment': this.payment.toMap(),
      'deliveryAddress': this.deliveryAddress.toMap(),
      'orderDeliveryDateTimeGMT': this.orderDeliveryDateTimeGMT,
      'stores': this.stores
    } as Map<String, dynamic>;
  }
}

class StoreOrder {
  final String orderId;
  final String storeId;
  final String branchId;
  final double storeOrderAmount;
  final DateTime orderDateTime;
  final List<OrderDetail> orderDetail;
  final List<OrderStage> orderStage;
  final String status;
  final String cancellationReasonCode;
  final String cancellationReason;
  final DateTime estimatedDeliveryTime;
  final String riderId;
  String storeName;

  StoreOrder(
      {this.orderId,
      this.storeId,
      this.branchId,
      this.storeOrderAmount,
      this.orderDateTime,
      this.orderDetail,
      this.orderStage,
      this.status,
      this.cancellationReasonCode,
      this.cancellationReason,
      this.estimatedDeliveryTime,
      this.riderId});

  factory StoreOrder.fromMap(Map<String, dynamic> map) {
    return new StoreOrder(
      orderId: map['orderId'] as String,
      storeId: map['storeId'] as String,
      branchId: map['branchId'] as String,
      storeOrderAmount: map['storeOrderAmount'] as double,
      orderDateTime: convertTimeStampToDatetime(map['orderDateTime']),
      orderDetail: List.from(map['orderDetail']).map((e) => OrderDetail.fromMap(e)).toList(),
      orderStage: List.from(map['orderStage']).map((e) => OrderStage.fromMap(e)).toList(),
      status: map['status'] as String,
      cancellationReasonCode: map['cancellationReasonCode'],
      cancellationReason: map['cancellationReason'],
      estimatedDeliveryTime: convertTimeStampToDatetime(map['estimatedDeliveryTime']),
      riderId: map['riderId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'orderId': this.orderId,
      'storeId': this.storeId,
      'branchId': this.branchId,
      'storeOrderAmount': this.storeOrderAmount,
      'orderDateTime': this.orderDateTime,
      'orderDetail': firesStoreOrderDetails(),
      'orderStage': fireStoreOrderStages(),
      'status': this.status,
      'cancellationReasonCode': this.cancellationReasonCode,
      'cancellationReason': this.cancellationReason,
      'estimatedDeliveryTime': this.estimatedDeliveryTime,
      'riderId': this.riderId,
    } as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> firesStoreOrderDetails() {
    List<Map<String, dynamic>> convertedOrderDetails = [];
    this.orderDetail.forEach((orderDetail) {
      OrderDetail _orderDetail = orderDetail;
      convertedOrderDetails.add(_orderDetail.toMap());
    });
    return convertedOrderDetails;
  }

  List<Map<String, dynamic>> fireStoreOrderStages() {
    List<Map<String, dynamic>> convertedOrderStages = [];
    this.orderStage.forEach((orderStage) {
      OrderStage _orderStage = orderStage;
      convertedOrderStages.add(_orderStage.toMap());
    });
    return convertedOrderStages;
  }
}

class OrderDetail {
  final String productId;
  final String productName;
  final String intlName;
  final double quantity;
  final double price;
  final String unit;
  final String imageUrl;

  OrderDetail({this.productId, this.productName, this.intlName, this.quantity, this.price, this.unit, this.imageUrl});

  factory OrderDetail.fromMap(Map map) {
    return OrderDetail(
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        intlName: map['intlName'] as String,
        quantity: map['quantity'] as double,
        price: map['price'] as double,
        unit: map['unit'] as String,
        imageUrl: map['imageUrl'] as String);
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'productId': this.productId,
      'productName': this.productName,
      'intlName': this.intlName,
      'quantity': this.quantity,
      'price': this.price,
      'unit': this.unit,
      'imageUrl': this.imageUrl
    } as Map<String, dynamic>;
  }
}

class OrderStage {
  final String stage;
  final DateTime stageChangeDatetime;

  OrderStage({this.stage, this.stageChangeDatetime});

  factory OrderStage.fromMap(Map map) {
    Timestamp time = map['stageChangeDatetme'];
    return OrderStage(
        stage: map['stage'] as String,
        stageChangeDatetime: DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch));
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'stage': this.stage,
      'stageChangeDatetme': this.stageChangeDatetime,
    } as Map<String, dynamic>;
  }
}
