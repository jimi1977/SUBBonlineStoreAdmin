import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/main.dart';
import 'package:subbonline_storeadmin/screens/user_login_widget.dart';

class UserLoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var orientation = MediaQuery.of(context).orientation;
    return SafeArea(
        child: Scaffold(
      //resizeToAvoidBottomInset: true,
      /*Avoid pushing contents up by keyboard*/
      body: Stack(
        fit: StackFit.loose,
        children: [
          Align(alignment: Alignment.bottomLeft, child: BackGroundPage()),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0),
              child: Text(
                "Welcome to SUBBOnline Store",
                style: TextStyle(fontFamily: 'Roboto', fontSize: 20),
              ),
            ),
          ),
          Align(
              alignment: orientation == Orientation.landscape ? Alignment.centerRight : Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                    height: orientation == Orientation.landscape ?  60 : 150,
                  ),
                  Container(
                    width: orientation == Orientation.landscape ? 400 : null,
                      child: UserLoginWidget()),
                ]),
              )),
        ],
      ),
    ));
  }
}
