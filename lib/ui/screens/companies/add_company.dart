import 'package:flutter/material.dart';
import 'package:rescape/data/company_list.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/logic/api/companies.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/shared/blocking_dialog.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class AddCompanyDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddCompanyDialogState();
  }
}

class _AddCompanyDialogState extends State<AddCompanyDialog> {
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationController = TextEditingController();

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
                  I18N.text('New Company'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextField(
                          controller: _companyNameController,
                          decoration: InputDecoration(
                            labelText: I18N.text('Company name'),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _companyAddressController,
                        decoration: InputDecoration(
                          labelText: I18N.text('Company address'),
                        ),
                      ),
                      TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: I18N.text('City'),
                        ),
                      ),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: I18N.text('Location'),
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
                            if (_companyNameController.text.isNotEmpty &&
                                _companyAddressController.text.isNotEmpty &&
                                _cityController.text.isNotEmpty &&
                                _locationController.text.isNotEmpty &&
                                int.tryParse(_locationController.text) !=
                                    null) {
                              BlockingDialog.show(context);
                              int statusCode = 400;
                              try {
                                final response = await CompaniesAPI.addNew({
                                  'name': _companyNameController.text,
                                  'address': _companyAddressController.text,
                                  'city': _cityController.text,
                                  'location':
                                      int.parse(_locationController.text),
                                });
                                statusCode = response.statusCode;
                                LocationList.addToInstance(LocationModel(
                                  id: response.body,
                                  companyName: _companyNameController.text,
                                  address: _companyAddressController.text,
                                  city: _cityController.text,
                                  number: _locationController.text,
                                ));
                              } catch (e) {
                                print('e');
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
}
