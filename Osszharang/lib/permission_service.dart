import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _key = 'permission_dialog_shown';

  // Ellenőrzi, hogy mutattuk-e már a popupot
  static Future<bool> shouldShowDialog() async {
    final prefs = await SharedPreferences.getInstance();
    // Ha még soha nem volt mentve (null), akkor mutassuk (true)
    return prefs.getBool(_key) ?? true;
  }

  // Elmenti, hogy a popup megjelent
  static Future<void> setDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
  }
}