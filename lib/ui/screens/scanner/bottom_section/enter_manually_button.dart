import 'package:flutter/material.dart';
import '../manual_entry/manual_entry_dialog.dart';

class EnterManuallyButton extends StatelessWidget {
  final Function scanning;

  EnterManuallyButton({@required this.scanning});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                'ENTER MANUALLY',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        onTap: () async {
          scanning(false, true);
          await showDialog(
            context: context,
            barrierColor: Colors.grey[50],
            builder: (context) => ManualEntryDialogDialog(),
          );
          scanning(true, false);
        },
      ),
    );
  }
}
