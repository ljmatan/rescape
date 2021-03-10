import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/api/companies.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/cache/prefs.dart';
import 'package:rescape/logic/storage/local.dart';
import 'package:rescape/ui/shared/overscroll_removed_behavior.dart';
import 'ui/screens/main/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set status and navigation bar colors
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await Prefs.init();

  await DB.init();

  if (ProductList.instance.isEmpty) await ProductsAPI.getList();

  await Companies.getList();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.openSans().fontFamily,
        primaryColor: const Color(0xff00875A),
        accentColor: const Color(0xffEDCA83),
        backgroundColor: const Color(0xff4A4A4A),
      ),
      builder: (context, child) => ScrollConfiguration(
        behavior: OverscrolLRemovedBehavior(),
        child: child,
      ),
      home: MainView(),
    );
  }
}
