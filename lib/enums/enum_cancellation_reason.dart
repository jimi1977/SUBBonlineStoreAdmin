

enum CancellationReasonEnum {
  CustomerRequest,
  OutOfStock,
  PaymentIssue,
  Other

}


String getCancellationReasonDescription(CancellationReasonEnum reason) {
  switch (reason){
    case CancellationReasonEnum.CustomerRequest:
      return "Order has been cancelled on Customer's request";
    case CancellationReasonEnum.OutOfStock:
      return "Requested Item(s) are out of stock.";
    case CancellationReasonEnum.PaymentIssue:
      return "Payment Dispute";
    case CancellationReasonEnum.Other:
      return "Other";
    default:
      return "Invalid Cancellation Reason";

  }


}