import 'package:flutter/material.dart';
import 'package:rescape/logic/api/organisation.dart';
import 'package:rescape/ui/shared/confirm_deletion_dialog.dart';

class RemoveEmployeeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RemoveEmployeeScreenState();
  }
}

class _RemoveEmployeeScreenState extends State<RemoveEmployeeScreen> {
  Future _getEmployees = OrganisationAPI().getEmployees();

  Key _futureKey = UniqueKey();

  void _rebuild() => setState(() {
        _getEmployees = OrganisationAPI().getEmployees();
        _futureKey = UniqueKey();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        key: _futureKey,
        future: _getEmployees,
        builder: (context, employees) =>
            employees.connectionState != ConnectionState.done ||
                    employees.hasError ||
                    !employees.hasData
                ? Center(
                    child: employees.connectionState != ConnectionState.done
                        ? CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              employees.hasError || !employees.hasData
                                  ? employees.error.toString()
                                  : '',
                            ),
                          ),
                  )
                : ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remove Employees',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      for (var employee in employees.data.entries)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: GestureDetector(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: kElevationToShadow[1],
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 64,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        employee.value['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.red.shade300,
                                        ),
                                        onPressed: () async {
                                          final Future _deleteEmployee =
                                              OrganisationAPI.deleteEmployee(
                                                  employee.key);
                                          await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ConfirmDeletionDialog(
                                              future: _deleteEmployee,
                                              rebuildParent: _rebuild,
                                            ),
                                          );
                                          _rebuild();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
