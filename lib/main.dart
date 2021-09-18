
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/route_generator.dart';
import 'package:subbonline_storeadmin/screens/store_selection.dart';
import 'package:subbonline_storeadmin/screens/subbonline_store_home_page.dart';
import 'package:subbonline_storeadmin/services/shared_preferences_service.dart';
import 'package:subbonline_storeadmin/signin/authwidget.dart';
import 'package:subbonline_storeadmin/signin/signin_page.dart';
import 'package:subbonline_storeadmin/signin/user_login_page.dart';
import 'package:subbonline_storeadmin/viewmodels/onboarding_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/user_login_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
    ], child: SubOnlineStoreApp()),
  );
  configLoading();

}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class SubOnlineStoreApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),

      debugShowCheckedModeBanner: false,
      title: 'SUBBonline Store',
      theme: ThemeData(
          primaryColor: Colors.white,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(elevation: 0.0),
          //This is important
          // timePickerTheme: TimePickerThemeData(
          //   backgroundColor: Colors.orangeAccent[200],
          //   shape:
          //   RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          //   hourMinuteShape: CircleBorder(),
          // ),
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: AuthWidget(
        nonSignedInBuilder: (_) => SignInPage(),
        signedInBuilder: (_) => Consumer(builder: (context, watch, _) {
          final didCompleteOnboarding = watch(onboardingViewModelProvider);
          final loginSuccessful = watch(userLoginViewModelProvider);
          return didCompleteOnboarding
              ? loginSuccessful
                  ? SubbOnlineStoreHomePage(title: kAppTitle)
                  : UserLoginPage()
              : OnBoardingPage();
          //MyHomePage(title: "This is SUBBonline Store App")
        }),
        //signedInBuilder: (_) => MyHomePage(title: "This is SUBBonline Store App"),
      ),
      //builder: EasyLoading.init(),
      //initialRoute: AuthWidget.id,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        /*Avoid pushing contents up by keyboard*/
        backgroundColor: Colors.white,
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
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  StoreSelection(),

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
    );
  }
}

class BackGroundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    double _heightFactor = 2;
    double _widthFactor = 1.4;
    if (orientation == Orientation.landscape) {
      _heightFactor = 1.8;
      _widthFactor = 2.3;
    }
    return Container(
        color: Colors.white,
        child: Image.asset(
          'images/subbonline_store_bg.jpg',
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomCenter,
          height: MediaQuery.of(context).size.height / _heightFactor,
          width: MediaQuery.of(context).size.width / _widthFactor,
        ));
  }
}
