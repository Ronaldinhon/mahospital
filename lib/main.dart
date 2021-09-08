import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mahospital/provider/auth_model.dart';
import 'package:mahospital/screen/login_screen.dart';
import 'package:mahospital/screen/profile_screen.dart';
import 'package:provider/provider.dart';
import 'provider/pt_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: PtList(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider<AuthModel>(
          create: (_) => AuthModel(),
          child: MaterialApp(
            home: Consumer<AuthModel>(
              builder: (_, auth, __) =>
                  auth.isSignedIn ? ProfileScreen() : LoginScreen(),
            ),
          ),
        ),
        routes: {
          '/profile': (context) => ProfileScreen(),
          '/login': (context) => LoginScreen(),
          // '/signup': (context) => SignupScreen(),
          // '/realtime_test': (context) => RealtimeTest(),
          // '/as_hosp': (context) => AsHospScreen(),
          // '/as_dept': (context) => AsDeptScreen(),
          // '/as_ward': (context) => AsWardScreen(),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) =>
                Scaffold(body: Center(child: Text('Not Found'))),
          );
        },
      ),
    );
  }
}
