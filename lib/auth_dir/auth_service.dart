import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final LocalAuthentication authentication = LocalAuthentication();
  Future<bool> authenticateUser() async {
    try {
      //canCheckBiometrics: Returns true if fingerprint/face hardware exists and is available.
      bool canCheckBiometrics = await authentication.canCheckBiometrics;
      print('Can check biometrics:$canCheckBiometrics');
      //  isDeviceSupported: Returns true if the device OS supports biometric APIs.
      bool isDeviceSupported = await authentication.isDeviceSupported();
      print("Is device supported: $isDeviceSupported");
      if (!canCheckBiometrics || !isDeviceSupported) return false;
      bool authenticate = await authentication.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: AuthenticationOptions(
          biometricOnly: false, // allow PIN/pattern fallback
          stickyAuth:
              true, // maintains auth state if app is paused,Useful for long sessions or app switching
          useErrorDialogs: true, // shows native Android error dialogs
        ),
      );
      if (authenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
      }
      print("Authentication result: $authenticate");
      return authenticate;
    } catch (e) {
      print("Error during authentication:$e");

      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false); // ✅ Clear login status
    SystemNavigator.pop();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAuthenticated') ?? false;
  }
}
