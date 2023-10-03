import 'package:shared_preferences/shared_preferences.dart';

class PrefrenceData {
  Future<void> setBillId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("billId", id);
  }

  Future<String?> getBillId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("billId").toString();
  }
}
