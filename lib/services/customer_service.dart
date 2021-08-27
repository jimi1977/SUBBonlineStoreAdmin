import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subbonline_storeadmin/models/customer.dart';
import 'package:subbonline_storeadmin/services/firestore_extensions.dart';

class CustomerService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String ref = "users";
  String errorMessage;

  Future<Customer> getCustomerDetails(String customerId) async {
    print("Customer ID $customerId");
    var snapshot =  await _firestore.collection(ref).doc(customerId)
        .getSavy()
    .catchError((onError) {
      errorMessage = onError.toString();
    });
    if (snapshot != null && snapshot.exists ) {
        return Customer.fromMap(snapshot);
    }
    return null;
  }
}
