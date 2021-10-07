// import 'package:flutter/material.dart';
// import '/helpers/local_navigator.dart';
// import '/helpers/reponsiveness.dart';
// import '/widgets/large_screen.dart';
// import '/widgets/medium_screen.dart';
// import '/widgets/side_menu.dart';

// import 'widgets/top_nav.dart';

// class SiteLayout extends StatelessWidget {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       extendBodyBehindAppBar: true,
//       appBar: topNavigationBar(context, scaffoldKey),
//       drawer: Drawer(
//         child: SideMenu(),
//       ),
//       body: ResponsiveWidget(
//         smallScreen: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: localNavigator(),
//         ),
//         mediumScreen: MediumScreen(),
//         largeScreen: LargeScreen(),
//       ),
//     );
//   }
// }
