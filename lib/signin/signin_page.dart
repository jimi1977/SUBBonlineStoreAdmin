import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/main.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/viewmodels/signin_view_model.dart';

final signInModelProvider =
    ChangeNotifierProvider<SignInViewModel>((ref) => SignInViewModel(auth: ref.watch(firebaseAuthProvider)));

class SignInPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final signInModel = watch(signInModelProvider);
    return ProviderListener<SignInViewModel>(
        provider: signInModelProvider,
        onChange: (context, model) async {
          if (model.error != null) {
            await showExceptionAlertDialog(
              context: context,
              title: "SignIn Failed",
              exception: model.error,
            );
          }
        },
        child: SafeArea(
          child: Scaffold(
            body: Stack(
            fit: StackFit.loose,
            children: [
              Align(
                  alignment: Alignment.bottomLeft,
                  child: BackGroundPage()),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0),
                  child: Text("Welcome to SUBBOnline Store", style: TextStyle(fontFamily: 'Roboto', fontSize: 20),),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 150,),
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      margin: EdgeInsets.all(30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      shadowColor: Colors.grey.shade300,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("SUBOnline Store App", style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Please Tap login button to SignIn", style: TextStyle(fontFamily: 'Roboto', fontSize: 14),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              child: Text("Login"),
                              onPressed: () {
                                signInModel.signInAnonymously();
                              },

                            ),
                          ),
                        ],
                      ),
                    )

                    // ElevatedButton(
                    //     onPressed: () async {
                    //       final onboardingViewModel = context.read(onboardingViewModelProvider.notifier);
                    //       await onboardingViewModel.completeOnboarding();
                    //     },
                    //     child: Text("Complete", style: TextStyle(color: Colors.white, fontSize: 16))),
                  ],
                ),
              ),

            ],
          ),
          ),
        ));
  }

  Future<void> showExceptionAlertDialog({
    @required BuildContext context,
    @required String title,
    @required dynamic exception,
  }) =>
      showAlertDialog(
        context: context,
        title: title,
        content: _message(exception),
        defaultActionText: 'OK',
      );

  String _message(dynamic exception) {
    if (exception is FirebaseException) {
      return exception.message ?? exception.toString();
    }
    if (exception is PlatformException) {
      return exception.message ?? exception.toString();
    }
    return exception.toString();
  }

  Future<bool> showAlertDialog({
    @required BuildContext context,
    @required String title,
    @required String content,
    String  cancelActionText,
    @required String defaultActionText,
  }) async {
    if (!Platform.isIOS) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelActionText != null)
              TextButton(
                child: Text(cancelActionText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            TextButton(
              child: Text(defaultActionText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }
  }
}
