import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rescape/logic/cache/prefs.dart';
import 'package:rescape/logic/i18n/locale_controller.dart';
import 'package:rescape/ui/screens/auth/auth_screen.dart';
import 'package:rescape/ui/screens/main/bloc/main_view_controller.dart';
import 'package:rescape/ui/screens/main/bottom_nav_bar/nav_bar_display.dart';
import 'package:rescape/ui/screens/main/pages/home/home_page.dart';
import 'package:rescape/ui/screens/main/pages/inventory/inventory_page.dart';
import 'package:rescape/ui/screens/main/pages/orders/orders_page.dart';
import 'package:rescape/ui/screens/main/pages/reports/reports_page.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainViewState();
  }
}

class _MainViewState extends State<MainView> {
  int _currentPage = 0;

  final _pageController = PageController();

  StreamSubscription _viewControllerSubscription;

  @override
  void initState() {
    super.initState();
    MainViewController.init();
    _viewControllerSubscription = MainViewController.stream.listen((page) {
      if (_currentPage != page) {
        _currentPage = page;
        _pageController.animateToPage(page,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    });
  }

  bool _authenticated = Prefs.instance.getBool('authenticated') ?? false;

  void _successfulAuthentication() => setState(() => _authenticated = true);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: LocaleController.stream,
      builder: (context, locale) => Scaffold(
        resizeToAvoidBottomInset: !_authenticated,
        body: _authenticated
            ? Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            HomePage(),
                            InventoryPage(),
                            OrdersPage(),
                            ReportsPage(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 56 + MediaQuery.of(context).padding.bottom,
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    child: BottomNavBar(),
                  ),
                ],
              )
            : AuthScreen(authenticated: _successfulAuthentication),
      ),
    );
  }

  @override
  void dispose() {
    _viewControllerSubscription.cancel();
    MainViewController.dispose();
    super.dispose();
  }
}
