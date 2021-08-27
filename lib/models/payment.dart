class Payment {
  final String paymentType;
  final String paymentSubType;
  String paymentStatus;
  final String mobileNumber;
  final String last6DigsCNIC;
  String paymentTransactionId;
  String creditCardNumber;
  String expiryDate;
  String cvv;
  String cardHolderName;

  Payment({this.paymentType, this.paymentSubType, this.paymentStatus, this.paymentTransactionId, this.mobileNumber, this.last6DigsCNIC, this.creditCardNumber, this.expiryDate, this.cvv, this.cardHolderName});

  factory Payment.fromMap(Map<String, dynamic> map) {
    return new Payment(
        paymentType: map['paymentType'] as String,
        paymentSubType: map['paymentSubType'] as String,
        paymentStatus: map['paymentStatus'] as String,
        mobileNumber: map['mobileNumber'],
        paymentTransactionId: map['paymentTransactionId'] as String);

  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'paymentType': this.paymentType,
      'paymentSubType': this.paymentSubType,
      'paymentStatus': this.paymentStatus,
      'mobileNumber': this.mobileNumber,
      'paymentTransactionId': this.paymentTransactionId
    } as Map<String, dynamic>;
  }
}
