import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rescape/data/models/user_model.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/api/organisation.dart';
import 'package:rescape/logic/cache/prefs.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:rescape/logic/i18n/i18n.dart';

class AuthScreen extends StatefulWidget {
  final Function authenticated;

  AuthScreen({@required this.authenticated});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();

  final _pinInputDecoration = BoxDecoration(
    color: const Color(0xffECECEC),
    borderRadius: BorderRadius.circular(4),
  );

  int _selected = 0;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty ||
        _usernameController.text.length < 6 ||
        _pinController.text.isEmpty ||
        int.tryParse(_pinController.text) == null) {
      Navigator.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(I18N.text('Please check your info'))));
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white70,
        builder: (context) => WillPopScope(
          child: Center(child: CircularProgressIndicator()),
          onWillPop: () async => false,
        ),
      );
      try {
        final response =
            await OrganisationAPI.login(_usernameController.text.toLowerCase());
        if (response.statusCode == 200) {
          final profile = jsonDecode(response.body);
          if (profile == null ||
              profile['pin'].toString() != _pinController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(I18N.text('Wrong details'))));
          } else if (profile['type'] != 'owner' && _selected == 0)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(I18N.text('Please select manager registration'))));
          else {
            UserData.setInstance(UserModel(profile['name'], profile['type']));
            await Prefs.instance.setBool('authenticated', true);
            await Prefs.instance.setString('name', profile['name']);
            await Prefs.instance.setString('userType', profile['type']);
            widget.authenticated();
          }
          Navigator.pop(context);
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: const Color(0xffEFEFEF)),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width / 2 - 12,
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                        left: _selected == 0
                            ? 0
                            : MediaQuery.of(context).size.width / 2 - 12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 12,
                            height: MediaQuery.of(context).size.width / 2 - 12,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: GestureDetector(
                          child: Image.asset(
                            'assets/owner.png',
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width / 2 - 32,
                            height: MediaQuery.of(context).size.width / 2 - 32,
                          ),
                          onTap: () {
                            if (_selected != 0) setState(() => _selected = 0);
                          },
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          child: Image.asset(
                            'assets/manager.png',
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width / 2 - 32,
                            height: MediaQuery.of(context).size.width / 2 - 32,
                          ),
                          onTap: () {
                            if (_selected != 1) setState(() => _selected = 1);
                          },
                        ),
                      ),
                    ],
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(52, 40, 52, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  I18N.text('Username'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xffECECEC),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                onSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 52),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  I18N.text('Passcode'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PinPut(
                                fieldsCount: 4,
                                controller: _pinController,
                                submittedFieldDecoration: _pinInputDecoration,
                                followingFieldDecoration: _pinInputDecoration,
                                disabledDecoration: _pinInputDecoration,
                                selectedFieldDecoration: _pinInputDecoration,
                                onSubmit: (_) async => await _login(),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(26, 26, 26, 16),
                          child: GestureDetector(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: kElevationToShadow[1],
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 48,
                                child: Center(
                                  child: Text(
                                    I18N.text('Verify'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () async => await _login(),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
