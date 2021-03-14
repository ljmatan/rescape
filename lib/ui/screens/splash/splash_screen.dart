import 'package:flutter/material.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/api/companies.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/cache/prefs.dart';
import 'package:rescape/logic/storage/local.dart';
import 'package:rescape/ui/screens/main/main_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  String _exception;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Prefs.init();

        await DB.init();

        if (ProductList.instance.isEmpty) await ProductsAPI.getList();

        await Companies.getList();

        UserData.init();
      } catch (e) {
        setState(() => _exception = e.toString());
      }

      if (_exception == null)
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainView()),
            (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Image.asset(
            'assets/splash.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          if (_exception != null)
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.white70),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _exception,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
