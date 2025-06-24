import 'package:flutter/material.dart';
import 'package:hive_financial_tracker_app/widgets/app_drawer.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Restore Screen'),
      ),
      drawer: AppDrawer(),
      body: Center(child: Text('Welcome to your Backup Restore Screen')),
    );
  }
}
