import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahospital/screen/404/error.dart';
import 'constants/firebase.dart';
import 'controllers/auth_controller.dart';
import 'controllers/list_all_ward_pt.dart';
import 'controllers/list_current_ward_pts_controller.dart';
import 'controllers/list_hosp_controller.dart';
import 'controllers/list_user_controller.dart';
import 'controllers/user_controller.dart';
import 'helpers/auth_middleware.dart';
import 'routing/routes.dart';
import 'screen/login_screen.dart';
import 'screen/profile_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  await initialization.then((value) {
    // Get.put(AppController());
    // Get.put(MenuController());
    // Get.put(NavigationController());
    // Get.put(AuthController());
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put(UserController());
    Get.put(HospListController());
    Get.put(UserListController());
    Get.put(AllWardPtListController());
    Get.put(CurrentWardPtsListController());
    // FirebaseFunctions.instanceFor(region: 'us-central1').useFunctionsEmulator('localhost', 5000);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: loginPageRoute,
      unknownRoute: GetPage(
          name: '/not-found',
          page: () => PageNotFound(),
          transition: Transition.fadeIn),
      getPages: [
        GetPage(name: profilePageRoute, page: () => ProfileScreen(), middlewares: [AuthMiddleware()]),
        GetPage(name: loginPageRoute, page: () => LoginScreen()),
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
