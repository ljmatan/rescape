import 'package:flutter/material.dart';
import 'package:rescape/logic/api/orders.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class ConfirmDeletionDialog extends StatefulWidget {
  final dynamic future;
  final Function rebuildParent;

  ConfirmDeletionDialog({@required this.rebuildParent, this.future});

  @override
  State<StatefulWidget> createState() {
    return _ConfirmDeletionDialogState();
  }
}

class _ConfirmDeletionDialogState extends State<ConfirmDeletionDialog> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Center(
        child: _confirmed
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    elevation: 2,
                    color: const Color(0xffEFEFEF),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18, top: 6),
                            child: Text(
                              I18N.text('Delete?'),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  onPrimary: Theme.of(context).primaryColor,
                                  primary: Colors.transparent,
                                ),
                                child: Text(I18N.text('Yes')),
                                onPressed: () async {
                                  setState(() => _confirmed = true);
                                  try {
                                    final response = widget.future == null
                                        ? await OrdersAPI.deleteProcessed()
                                        : await widget.future();
                                    if (response.statusCode == 200) {
                                      await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          barrierColor: Colors.white70,
                                          builder: (context) =>
                                              ResultDialog(statusCode: 200));
                                      widget.rebuildParent();
                                    }
                                  } catch (e) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              const SizedBox(width: 14),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                ),
                                child: Text(I18N.text('No')),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
      onWillPop: () async => false,
    );
  }
}
