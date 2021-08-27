enum OrderStageEnum {
  OrderReceived,
  OrderConfirmed,
  InProgress,
  OutForDelivery,
  Delivered,
  OrderCancelled
}

OrderStageEnum orderStageEnumTypeFromString(String typeString) {
  return OrderStageEnum.values
      .firstWhere((type) => type.toString() == "OrderStageEnum." + typeString);
}
int getOrderStageEnumIndex(OrderStageEnum stage) {
  List<OrderStageEnum> _stages = OrderStageEnum.values;
  return _stages.indexOf(stage);
}
String orderStageDescription(OrderStageEnum orderStageEnum) {
  switch (orderStageEnum) {
    case OrderStageEnum.OrderReceived:
      return "Order Received";
    case OrderStageEnum.OrderConfirmed:
      return "Order Confirmed";
    case OrderStageEnum.InProgress:
      return "In Progress";
    case OrderStageEnum.OutForDelivery:
      return "Out for delivery";
    case OrderStageEnum.Delivered:
      return "Delivered";
    case OrderStageEnum.OrderCancelled:
      return "Order Cancelled";
    default:
      return "Invalid Order Stage";
  }
}
enum OrderCancelledEnum {
  OrderCancelled
}
OrderCancelledEnum orderCancelledEnumTypeFromString(String typeString) {

  return OrderCancelledEnum.values
      .firstWhere((type) => type.toString() == "OrderCancelledEnum." + typeString);
}

String orderCancelledDescription(OrderCancelledEnum orderCancelledEnum) {
  switch (orderCancelledEnum) {
    case OrderCancelledEnum.OrderCancelled:
      return "Order Cancelled";
    default:
      return "Invalid Order Status";
  }
}