import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/enums/order_satges_enum.dart';
import 'package:subbonline_storeadmin/models/customer.dart';
import 'package:subbonline_storeadmin/models/customer.dart';
import 'package:subbonline_storeadmin/models/customer.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/customer_service.dart';
import 'package:subbonline_storeadmin/services/order_service.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final Future<List<Order>> orders;

  const OrderLoaded(this.orders);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderLoaded && o.orders == orders;
  }

  @override
  int get hashCode => orders.hashCode;
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

final storeOrderViewModelProvider = StateNotifierProvider.autoDispose(
    (ref) => StoreOrdersViewModel(ref.watch(orderServiceProvider), ref.watch(customerOrderServiceProvider)));

class StoreOrdersViewModel extends StateNotifier<OrderState> {
  StoreOrdersViewModel(this.orderService, this.customerService) : super(OrderInitial());

  final OrderService orderService;
  final CustomerService customerService;

  final customerCache = AsyncCache<Customer>(const Duration(minutes: 60));

  Customer _customer;

  String errorMessage;

  Customer get customer => _customer;

  Stream<QuerySnapshot> ordersStream;

  Stream<DocumentSnapshot> storeOrderStream;

  set customer(Customer value) {
    _customer = value;
  }

  updateState() {
    state = OrderInitial();
  }


  Future<Customer> getCustomerDetails(String customerId) async {
    try {
      return customerCache.fetch(() =>  customerService.getCustomerDetails(customerId));
      
      //_customer = await customerService.getCustomerDetails(customerId);
      //return _customer;
    } catch (e) {
      errorMessage = e.toString();
      throw (errorMessage);
    }
  }

  Stream<QuerySnapshot> getStoreOrdersNew(String storeId) {
    try {
      //state = OrderLoading();

      ordersStream =  orderService.getOrdersByStoreNew(storeId);
      return ordersStream;
    } on Exception {
      state = OrderError("Couldn't fetch orders. Is the device online?");
    }
  }

  Stream<DocumentSnapshot> getOrderStreamByOrderId(String orderId) {
    return orderService.getOrderStreamByOrderId(orderId);
  }

  Stream<QuerySnapshot>  getStoreOrdersReceivedByStoreId(String storeId, String branchId, String orderType) {
    final container = ProviderContainer();
    if (orderType == "New") {
      return  orderService.getStoreOrdersByStoreIdAndStatus(storeId, branchId, OrderStageEnum.OrderReceived.toString().split(".")[1]);
    }
    else if (orderType == "InProgress") {
      List<String> _statuses = [OrderStageEnum.OrderConfirmed.toString().split(".")[1],
        OrderStageEnum.InProgress.toString().split(".")[1],
        OrderStageEnum.OutForDelivery.toString().split(".")[1]];
      return  orderService.getStoreOrdersByStoreIdAndStatuses(storeId, branchId, _statuses);
    }
    else if (orderType == "PastOrders") {
      List<String> _statuses = [OrderStageEnum.Delivered.toString().split(".")[1],
        OrderStageEnum.OrderCancelled.toString().split(".")[1]];
      return  orderService.getStoreOrdersByStatusesWithLimit(storeId, branchId, _statuses, 10);
    }

  }

  Stream<QuerySnapshot> getPastStoreOrders(String storeId, String branchId, DateTime ordersDate, int limit) {
    List<String> _statuses = [OrderStageEnum.Delivered.toString().split(".")[1],
      OrderStageEnum.OrderCancelled.toString().split(".")[1]];
    return orderService.getStoreOrdersByStatusesWithDateAndLimit(storeId, branchId, _statuses, ordersDate, limit);
  }

  Stream<DocumentSnapshot> getStoreOrdersOfStore(String orderId, String storeId, String branchId) {
    storeOrderStream = orderService.getStoreOrdersOfStore(orderId, storeId, branchId);
    return storeOrderStream;
  }

  Future<Order> getOrderByOrderId(String orderId) async {
    return await orderService.getOrderById(orderId);

  }

  Future<List<Order>> getOrdersByOrderIds(List<StoreOrder> storeOrders) async {
    List<Order> orders = [];
    for (var storeOrder in storeOrders) {
       var order = await orderService.getOrderById(storeOrder.orderId);
       if (order != null) {
         order.storeOrders = storeOrder;
         orders.add(order);
       }
    }
    return orders;

  }

  List<Order> getOrdersFromSnapShot(QuerySnapshot snapshot) {
    return snapshot.docs.map((docs) => Order.fromMap(docs.data())).toList();
  }

  Order getOrderFromSnapShot(DocumentSnapshot snapshot) {
    return Order.fromMap(snapshot.data());
  }

  List<StoreOrder> getStoresOrdersFromSnapShot(QuerySnapshot snapshot) {
    return snapshot.docs.map((docs) => StoreOrder.fromMap(docs.data())).toList();
  }

  List<Order> populateStoreOrder(String orderType, List<Order> orders, StoreOrder storeOrder, int index) {
    if (orderType == "New") {
      if (storeOrder.orderStage.last.stage == OrderStageEnum.OrderReceived.toString().split(".")[1]) {
        orders[index].storeOrders = storeOrder;
      } else
        {
          orders.remove(index);
        }
    }
    return orders;

  }

  acceptOrder(Order order) {
    try {
      orderService.updateOrderStage(order, OrderStageEnum.OrderConfirmed);
    } on Exception catch (e) {
      errorMessage = orderService.errorMessage;
    }
  }

  startProcessingOrder(Order order) {
    try {
      orderService.updateOrderStage(order, OrderStageEnum.InProgress);
    } on Exception catch (e) {
      errorMessage = orderService.errorMessage;
    }
  }
  updateOrderStatus(Order order, OrderStageEnum stage) {
    try {
      orderService.updateOrderStage(order, stage);
    } on Exception catch (e) {
      errorMessage = orderService.errorMessage;
    }
  }
  cancelOrder(Order order, OrderCancelledEnum cancelledEnum, String cancellationReasonCode, String cancellationReason) {
    try {
      orderService.cancelOrder(order, cancelledEnum, cancellationReasonCode, cancellationReason);
    } on Exception catch (e) {
      errorMessage = orderService.errorMessage;
    }
  }


}
