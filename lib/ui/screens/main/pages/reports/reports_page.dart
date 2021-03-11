import 'package:flutter/material.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/ui/screens/main/pages/reports/damages/damages_screen.dart';
import 'package:rescape/ui/screens/scanner/camera_screen.dart';
import 'damage_report/damage_report_screen.dart';

class ReportsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportsPageState();
  }
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        top: MediaQuery.of(context).padding.top + 16,
        right: 16,
        bottom: 32,
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dangerous, size: 64),
                      Text(
                        'Damage' + (UserData.isOwner ? 's' : ''),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => UserData.isOwner
                      ? DamagesScreen()
                      : DamageReportScreen())),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.post_add, size: 64),
                      Text(
                        'Return' + (UserData.isOwner ? 's' : ''),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => UserData.isOwner
                      ? CameraScreen()
                      : DamageReportScreen())),
            ),
          ),
        ],
      ),
    );
  }
}
