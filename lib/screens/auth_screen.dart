import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_dir/auth_service.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final AuthService _authService=AuthService();
@override
  void initState(){
    super.initState();
  _checkAuth();

}

void _checkAuth()async{
  bool alreadyLoggedIn=await _authService.isLoggedIn();
  if(alreadyLoggedIn){
    Navigator.pushReplacementNamed(context, '/dashboard');
    return;
  }
  bool isAuthenticated=await _authService.authenticateUser();
  if(isAuthenticated){
    final prefs=await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication failed')));

  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentication screen'),),
      body: Center(
        child: ElevatedButton(onPressed: _checkAuth, child: Text('Authenticate'),),
      ),
    );
  }
}
