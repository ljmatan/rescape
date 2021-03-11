import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rescape/logic/api/reports.dart';
import 'package:rescape/ui/screens/main/pages/reports/damages/damage_model.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class DamagesScreen extends StatelessWidget {
  static final Future _getDamageReports = ReportsAPI.getDamageReports();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Text(
          'Damages',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getDamageReports,
        builder: (context, damages) {
          if (damages.connectionState != ConnectionState.done ||
              damages.hasError ||
              !damages.hasData)
            return Center(
              child: damages.connectionState != ConnectionState.done
                  ? CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        damages.hasError
                            ? damages.error.toString()
                            : 'No damages recorded',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            );
          else {
            return ListView.builder(
              reverse: false,
              itemCount: damages.data.entries.length,
              itemBuilder: (context, i) {
                final damage = DamageModel(
                  time: DateTime.parse(
                      damages.data.entries.elementAt(i).value['time']),
                  from: damages.data.entries.elementAt(i).value['from'],
                  message: damages.data.entries.elementAt(i).value['message'],
                  image: damages.data.entries.elementAt(i).value['image'],
                );
                return Padding(
                  padding: EdgeInsets.fromLTRB(16, i == 0 ? 16 : 0, 16, 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: kElevationToShadow[1],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(damage.from),
                                    Text(damage.time.day.toString() +
                                        '.' +
                                        damage.time.month.toString() +
                                        '.' +
                                        damage.time.year.toString() +
                                        '.'),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  if (damage.image != null)
                                    IconButton(
                                      icon: Icon(Icons.image),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => Center(
                                          child: Image.memory(
                                              base64Decode(damage.image)),
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.delete_forever),
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        barrierColor: Colors.white70,
                                        builder: (context) => WillPopScope(
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          onWillPop: () async => false,
                                        ),
                                      );
                                      try {
                                        final response =
                                            await ReportsAPI.deleteReport(
                                                damages.data.entries
                                                    .elementAt(i));
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          barrierColor: Colors.white70,
                                          builder: (context) => ResultDialog(
                                            statusCode: response.statusCode,
                                          ),
                                        );
                                      } catch (e) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                                SnackBar(content: Text('$e')));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (damage.message != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Text(damage.message),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
