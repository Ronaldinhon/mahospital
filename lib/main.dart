import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahospital/controllers/entry_chart_controller.dart';
import 'package:mahospital/screen/404/error.dart';
import 'package:mahospital/screen/sign_chop.dart';
import 'constants/controllers.dart';
import 'constants/firebase.dart';
import 'controllers/auth_controller.dart';
// import 'controllers/list_all_ward_pt.dart';
import 'controllers/list_all_ward_pts_controller.dart';
import 'controllers/list_current_ward_pts_controller.dart';
import 'controllers/list_dept_controller.dart';
import 'controllers/list_hosp_controller.dart';
import 'controllers/list_user_controller.dart';
import 'controllers/sum_rer_controller.dart';
import 'controllers/user_controller.dart';
import 'helpers/auth_middleware.dart';
import 'routing/routes.dart';
import 'screen/as_hosp_screen.dart';
import 'screen/login_screen.dart';
import 'screen/profile_screen.dart';
// import 'package:cloud_functions/cloud_functions.dart';

import '/constants/style.dart';
// import '/controllers/menu_controller.dart';
// import '/controllers/navigation_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  Get.put<AuthController>(AuthController(), permanent: true);
  await initialization.then((value) {
    // Get.put(AppController());
    // Get.put(MenuController());
    // Get.put(NavigationController());
    // Get.put(AuthController());
    Get.put(UserController());
    Get.put(HospListController());
    Get.put(UserListController());
    Get.put(AllWardPtListController());
    Get.put(CurrentWardPtsListController());
    Get.put(EntryChartController());
    Get.put(DeptListController());
    // Get.put(SumRerController());
    // FirebaseFunctions.instanceFor(region: 'us-central1').useFunctionsEmulator('localhost', 4000);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // This widget is the root of your application.

  Timer timer = Timer(Duration(days: 1), () {});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == (AppLifecycleState.detached)) {
      authController.signOut();
      timer.cancel();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      print('in/paused');
      timer = Timer(Duration(minutes: 1), () => authController.signOut());
    } else if (state == AppLifecycleState.resumed) {
      timer.cancel();
      print('resumed');
    }
  }

  // @override
  // void dispose(){
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: loginPageRoute,
      unknownRoute: GetPage(
          name: '/not-found',
          page: () => PageNotFound(),
          transition: Transition.fadeIn),
      getPages: [
        GetPage(
            name: profilePageRoute,
            page: () => ProfileScreen(),
            middlewares: [AuthMiddleware()]),
        GetPage(
          name: loginPageRoute,
          page: () => LoginScreen(),
        ),
        GetPage(name: asHospPageRoute, page: () => AsHospScreen()),
        GetPage(name: signChopRoute, page: () => SignChop()),
      ],
      debugShowCheckedModeBanner: false,
      title: 'MaHospital',
      theme: ThemeData(
          scaffoldBackgroundColor: light,
          textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.black),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          }),
          primarySwatch: Colors.blue,
          // primaryTextTheme: TextTheme(bodyMedium: TextStyle(fontSize: 20.0))
          highlightColor: Colors.black
          ),
      // home: Root(),
    );
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider.value(
    //       value: PtList(),
    //     ),
    //   ],
    //   child: MaterialApp(
    //     title: 'Flutter Demo',
    //     theme: ThemeData(
    //       primarySwatch: Colors.blue,
    //     ),
    //     // home: ChangeNotifierProvider<AuthModel>(
    //     //   create: (_) => AuthModel(),
    //     //   child: MaterialApp(
    //     //     home: Consumer<AuthModel>(
    //     //       builder: (_, auth, __) =>
    //     //           auth.isSignedIn ? ProfileScreen() : LoginScreen(),
    //     //     ),
    //     //   ),
    //     // ),
    //     routes: {
    //       '/': (context) => ProfileScreen(),
    //       '/login': (context) => LoginScreen(),
    //       '/signup': (context) => SignupScreen(),
    //       // '/realtime_test': (context) => RealtimeTest(),
    //       // '/as_hosp': (context) => AsHospScreen(),
    //       // '/as_dept': (context) => AsDeptScreen(),
    //       // '/as_ward': (context) => AsWardScreen(),
    //     },
    //     onUnknownRoute: (RouteSettings settings) {
    //       return MaterialPageRoute<void>(
    //         settings: settings,
    //         builder: (BuildContext context) =>
    //             Scaffold(body: Center(child: Text('Not Found'))),
    //       );
    //     },
    //   ),
    // );
  }
}
