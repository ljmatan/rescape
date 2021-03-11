import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rescape/logic/api/reports.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class DamageReportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DamageReportScreenState();
  }
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final _messageController = TextEditingController();

  io.File _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Text(
          'Damage report',
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
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _image == null
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                      ),
                      onTap: () async {
                        FilePickerResult result =
                            await FilePicker.platform.pickFiles();
                        if (result != null)
                          setState(
                              () => _image = io.File(result.files.single.path));
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Image.file(_image),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  minLines: 2,
                  maxLines: 2,
                  controller: _messageController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'Enter a message',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: Center(
                              child: Text(
                                'CANCEL',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              child: Center(
                                child: Text(
                                  'SUBMIT',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (_messageController.text.length > 10 ||
                                _image != null) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.white70,
                                builder: (context) => WillPopScope(
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                  onWillPop: () async => false,
                                ),
                              );
                              try {
                                final response =
                                    await ReportsAPI.newDamageReport(
                                  _messageController.text,
                                  _image != null
                                      ? base64Encode(_image.readAsBytesSync())
                                      : null,
                                );
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.white70,
                                  barrierDismissible: false,
                                  builder: (context) => ResultDialog(
                                      statusCode: response.statusCode),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$e')));
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
