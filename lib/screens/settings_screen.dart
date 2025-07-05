import 'package:flutter/material.dart';
import 'package:hive_financial_tracker_app/main.dart';
import 'package:hive_financial_tracker_app/viewmodel_controller/theme_provider.dart';
import 'package:hive_financial_tracker_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _budgetController=TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadBudget();
  }

  void _loadBudget()async{
    final prefs=await SharedPreferences.getInstance();
    final budget = prefs.getDouble('monthlyBudget')??0.0;
    _budgetController.text=budget.toString();
  }
  void _saveBudget()async{
    final prefs=await SharedPreferences.getInstance();
    final budget= double.tryParse(_budgetController.text)??0.0;
    await prefs.setDouble('monthlyBudget', budget);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Budget saved')));

  }
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
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Budget",
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: _saveBudget, child: Text("Save Budget"),),
          ],
        ),),
    );
  }
}