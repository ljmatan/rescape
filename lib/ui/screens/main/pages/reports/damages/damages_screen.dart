import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rescape/logic/api/reports.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/reports/damages/damage_model.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class DamagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Text(
          I18N.text('Damages'),
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
        future: ReportsAPI.getDamageReports(),
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
                            : I18N.text('No damages recorded'),
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
                  key: damages.data.entries.elementAt(i).key,
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
                                        builder: (context) => Material(
                                          color: Colors.white70,
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: InteractiveViewer(
                                                  constrained: false,
                                                  child: Image.memory(
                                                    base64Decode(damage.image),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                child: IconButton(
                                                  icon: Icon(Icons.close),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ),
                                            ],
                                          ),
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
                                                damage.key);
                                        Navigator.pop(context);
                                        ResultDialog.show(
                                            context, response.statusCode);
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
