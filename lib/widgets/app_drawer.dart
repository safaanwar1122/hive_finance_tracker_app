import 'package:flutter/material.dart';



class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal
            ),
            child: Text('Expense Tracker',
            style: TextStyle(color: Colors.white, fontSize: 24),),),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Authentication'),
            onTap: ()=>Navigator.pushReplacementNamed(context, '/authScreen'),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: ()=>Navigator.pushReplacementNamed(context,'/dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Transaction'),
            onTap: ()=>Navigator.pushReplacementNamed(context,'/add-transaction' ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Transaction'),
            onTap: ()=>Navigator.pushReplacementNamed(context, '/transactions'),
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Categories'),
            onTap: () => Navigator.pushReplacementNamed(context, '/categories'),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Analytics'),
            onTap: () => Navigator.pushReplacementNamed(context, '/analytics'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Monthly Report  '),
            onTap: () => Navigator.pushReplacementNamed(context,  '/monthlyReport'),
          ),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('BackUp/Restore '),
            onTap: () => Navigator.pushReplacementNamed(context, '/backup'),
          ),
        ],
      ),
    );
  }
}
