import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mahospital/routing/routes.dart';
import 'provider/auth_model.dart';
import 'screen/login_screen.dart';
import 'screen/profile_screen.dart';
import 'package:provider/provider.dart';
import 'provider/pt_list.dart';
import 'screen/signup_screen.dart';

import '/constants/style.dart';
import '/controllers/menu_controller.dart';
import '/controllers/navigation_controller.dart';
import '/layout.dart';
import '/pages/404/error.dart';
import '/pages/authentication/authentication.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  Get.put(MenuController());
  Get.put(NavigationController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: authenticationPageRoute,
      unknownRoute: GetPage(
          name: '/not-found',
          page: () => PageNotFound(),
          transition: Transition.fadeIn),
      getPages: [
        GetPage(
            name: rootRoute,
            page: () {
              return SiteLayout();
            }),
        GetPage(
            name: authenticationPageRoute, page: () => AuthenticationPage()),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
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
      // home: AuthenticationPage(),
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
