import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:billing_software/providers/bills.dart';
import 'package:billing_software/providers/products.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/customers.dart';

class data {
  Future<String> _getLocalDataPath() async {
    final directory = await getApplicationCacheDirectory();
    return directory.path;
  }

  Future<void> createFile(String filename, Map<String, dynamic> data) async {
    final localDataPath = await _getLocalDataPath();
    print("signupData $data");
    final jsonData = jsonEncode(data);

    final jsonFile = File('$localDataPath/$filename');
    try {
      await jsonFile.writeAsString(jsonData);
      print("File created.");
    } catch (e) {
      print("Error creating file: $e");
    }
  }

  Future<String?> retrieveAccessToken(String filename) async {
    final localDataPath = await _getLocalDataPath();
    print(localDataPath);
    final jsonFile = File('$localDataPath/$filename');

    try {
      final jsonData = await jsonFile.readAsString();
      final accessTokenMap = json.decode(jsonData);
      return accessTokenMap['userDetails'][0]['token'];
    } catch (e) {
      print("Error reading access token: $e");
      return null;
    }
  }

  Future<dynamic> fetchDataFromFile(String filename, key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData;
      if (key == Keys.user) {
        userData = jsonDataMap[key][0] as Map<String, dynamic>;
      } else {
        userData = jsonDataMap[key] as List<dynamic>;
      }
      print("FileData : $userData");
      return userData;
    } catch (e) {
      print("Error reading file: $e");
    }
    return {};
  }

  Future<void> addNewDataToFile(
      String filename, Map<String, dynamic> data) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap['userData'] as List<dynamic>;
      userData.add(data);
      final newJsonData = jsonEncode({
        'userData': userData,
      });
      await jsonFile.writeAsString(newJsonData);
      final absolutePath = path.absolute(jsonFile.path);
      print("Data saved to file: $absolutePath");
      print("FileData : $userData");
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Future<bool> deleteFiles(BuildContext context) async {
    try {
      List<String> files = [
        'user.json',
        'customer.json',
        'bill.json',
        'product.json',
      ];
      Provider.of<Customers>(context, listen: false).clearCustomers();
      Provider.of<Products>(context, listen: false).clearProducts();
      Provider.of<Bills>(context, listen: false).clearBills();
      for (String file in files) {
        final localDataPath = await _getLocalDataPath();
        final jsonFile = File('$localDataPath/$file');
        await jsonFile.delete();
        print("File deleted: $file");
      }

      return true;
    } catch (e) {
      if (e.toString().contains("No such file or directory")) {
        print("File does not exist: ");
        return false;
      } else {
        print("Error deleting file: $e");
        return false;
      }
      return false;
    }
  }

  Future<void> deleteUserDataById(String filename, String id) async {
    final jsonFile = File(filename);
    try {
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap['userData'] as List<dynamic>;
      userData.removeWhere((user) => user['id'] == id);
      final newJsonData = jsonEncode({
        'userData': userData,
      });
      await jsonFile.writeAsString(newJsonData);
      print("User data with id '$id' deleted.");
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Future<void> updateUserDataById(
      String filename, String id, Map<String, dynamic> newData) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap[Keys.user] as List<dynamic>;
      final userIndex = userData.indexWhere((user) => user['id'] == id);
      if (userIndex != -1) {
        userData[userIndex].addAll(newData);
        final newJsonData = jsonEncode({
          Keys.user: userData,
        });
        await jsonFile.writeAsString(newJsonData);
        print("User data with id '$id' updated.");
      } else {
        print("User with id '$id' not found.");
      }
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }
}
