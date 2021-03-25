import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rescape/logic/api/organisation.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddEmployeeScreenState();
  }
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  int _pin;
  String _type = 'worker';

  @override
  void initState() {
    super.initState();
    _pin = 1000 + Random().nextInt(9000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  I18N.text('New Employee'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18, top: 10),
                  child: Text(
                    'PIN: $_pin',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: I18N.text('First Name'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: I18N.text('Last Name'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(I18N.text('Type') + ':'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 22,
                        child: DropdownButton(
                          value: _type,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              child: Text(I18N.text('Worker')),
                              value: 'worker',
                            ),
                            DropdownMenuItem(
                              child: Text(I18N.text('Manager')),
                              value: 'manager',
                            ),
                            DropdownMenuItem(
                              child: Text(I18N.text('Owner')),
                              value: 'owner',
                            ),
                          ],
                          onChanged: (value) => setState(() => _type = value),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: Center(
                              child: Text(
                                I18N.text('CANCEL'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              child: Center(
                                child: Text(
                                  I18N.text('CONFIRM'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            if (_firstNameController.text.isNotEmpty &&
                                _lastNameController.text.isNotEmpty) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.white70,
                                builder: (context) => WillPopScope(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  onWillPop: () async => false,
                                ),
                              );
                              String username = _firstNameController.text +
                                  _lastNameController.text;
                              username = username
                                  .replaceAll('č', 'c')
                                  .replaceAll('ć', 'c')
                                  .replaceAll('š', 's')
                                  .replaceAll('ž', 'z')
                                  .replaceAll('đ', 'd')
                                  .replaceAll(' ', '')
                                  .toLowerCase();
                              int statusCode;
                              try {
                                statusCode = (await OrganisationAPI.newEmployee(
                                  _firstNameController.text,
                                  _lastNameController.text,
                                  username,
                                  _pin,
                                  _type,
                                ))
                                    .statusCode;
                              } catch (e) {
                                statusCode = 400;
                              }
                              Navigator.pop(context);
                              ResultDialog.show(context, statusCode);
                            } else
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(I18N.text(
                                      'Please enter all of the required info'))));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
