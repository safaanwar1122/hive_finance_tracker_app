import 'package:flutter/material.dart';
import 'package:hive_financial_tracker_app/main.dart';
import 'package:hive_financial_tracker_app/viewmodel_controller/theme_provider.dart';
import 'package:hive_financial_tracker_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Screen'),
      ),
      drawer: AppDrawer(),
      body:Padding(padding: const EdgeInsets.all(16.0),

      child: Column(
        children: [
          SwitchListTile (
            title: Text('Set Theme'),
            value: context.watch<ThemeProvider>().isDark,
            onChanged: ( value) {
              context.read<ThemeProvider>().toggleTheme(value);
            },

          )
        ],
      ),),
    );
  }
}
