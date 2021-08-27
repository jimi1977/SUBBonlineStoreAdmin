import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SignInViewModel with ChangeNotifier {
  SignInViewModel({@required this.auth});

  final FirebaseAuth auth;
  bool isLoading = false;
  dynamic error;

  Future<void> _signIn(Future<UserCredential> Function() signMethod) async {
    try {
      isLoading = true;
      notifyListeners();
      await signMethod();
      error = null;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _signOut(Future<void> signOutMethod) async {
    try{
      isLoading = true;
      notifyListeners();
      await signOutMethod;
      error = null;

    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> userSignIn() async {
    User user = auth.currentUser;
    if (user == null) {
      await _signIn(auth.signInAnonymously);
    }
    if (user.isAnonymous) {

    }
  }

  Future<void> signInAnonymously() async {
    await _signIn(auth.signInAnonymously);
  }
  Future<void> signOut() async {
    await _signOut(auth.signOut());
  }
}
