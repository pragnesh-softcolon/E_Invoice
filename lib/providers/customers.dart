import 'dart:convert';
import 'dart:io';

import 'package:billing_software/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Customers with ChangeNotifier {
  List<CustomerData> _customers = [];

  List<String> _deletedCustomerId = [];

  /// clear _customers list
  void clearCustomers() {
    _customers.clear();
    notifyListeners();
  }

  /// gst is exist or not
  bool isGstExist(String gst) {
    for (var iteam in _customers) {
      if (iteam.gstin == gst) {
        return true;
      }
    }
    return false;
  }

  /// find data by GSTIN and update id in Json file
  Future<void> updateIdByGstinInFile(
      String filename, List<dynamic> resData, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      for (var iteam in resData) {
        for (var buyerIteam in jsonDataMap[key]) {
          if (iteam['GST'] == buyerIteam['Gstin']) {
            buyerIteam['id'] = iteam['id'];
            buyerIteam['buyer'] = false;
            break;
          }
        }
      }
      String updatedJsonData = jsonEncode(jsonDataMap);
      print("updated $updatedJsonData");
      await jsonFile.writeAsString(updatedJsonData);
      final newData = jsonDataMap[key] as List<dynamic>;
      final List<CustomerData> loadedData = [];
      newData.forEach((data) {
        loadedData.add(
          CustomerData(
            id: data['id'],
            name: data['Nm'],
            gstin: data['Gstin'],
            address: data['Addr1'],
            location: data['Loc'],
            stateCode: data['Stcd'],
            pinCode: data['Pin'],
          ),
        );
      });
      _customers = loadedData;
      notifyListeners();
      notifyListeners();
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Future<void> updateStatusByIdInFile(
      String filename, List<dynamic> resData, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      resData.forEach((id) {
        for (var buyerIteam in jsonDataMap[key]) {
          if (id == buyerIteam['id']) {
            buyerIteam['buyer'] = false;
            break;
          }
        }
      });
      String updatedJsonData = jsonEncode(jsonDataMap);
      print("updated $updatedJsonData");
      await jsonFile.writeAsString(updatedJsonData);
      final newData = jsonDataMap[key] as List<dynamic>;
      final List<CustomerData> loadedData = [];
      newData.forEach((data) {
        loadedData.add(
          CustomerData(
            id: data['id'],
            name: data['Nm'],
            gstin: data['Gstin'],
            address: data['Addr1'],
            location: data['Loc'],
            stateCode: data['Stcd'],
            pinCode: data['Pin'],
          ),
        );
      });
      _customers = loadedData;
      notifyListeners();
      notifyListeners();
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  CustomerData findById(String id) {
    return _customers.firstWhere((customer) => customer.id == id);
  }

  List<CustomerData> get customers {
    return [..._customers];
  }

  List<String> get deletedCustomerId {
    return [..._deletedCustomerId];
  }

  Future<String> _getLocalDataPath() async {
    final directory = await getApplicationCacheDirectory();
    return directory.path;
  }

  Future<void> addNewDataToFile(
      String filename, Map<String, dynamic> data, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap[key] as List<dynamic>;
      userData.add(data);
      final newJsonData = jsonEncode({
        key: userData,
      });
      await jsonFile.writeAsString(newJsonData);
      print("FileData : $userData");
      final List<CustomerData> loadedData = [];
      userData.forEach((data) {
        loadedData.add(
          CustomerData(
            id: data['id'],
            name: data['Nm'],
            gstin: data['Gstin'],
            address: data['Addr1'],
            location: data['Loc'],
            stateCode: data['Stcd'],
            pinCode: data['Pin'].toString(),
          ),
        );
      });
      _customers = loadedData;
      notifyListeners();
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Future<void> fetchDataFromFile(String filename, key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap[key] as List<dynamic>;
      final List<CustomerData> loadedData = [];
      userData.forEach((data) {
        loadedData.add(
          CustomerData(
            id: data['id'],
            name: data['Nm'],
            gstin: data['Gstin'],
            address: data['Addr1'],
            location: data['Loc'],
            stateCode: data['Stcd'],
            pinCode: data['Pin'].toString(),
          ),
        );
      });
      _customers = loadedData;
      notifyListeners();
      print("FileData : $userData");
    } catch (e) {
      print("Error reading file: $e");
    }
  }

  Map<String, dynamic> modifyMap(Map<String, dynamic> originalMap) {
    originalMap.remove("__v");
    originalMap.remove("createdAt");
    originalMap.remove("updatedAt");
    originalMap.addAll({
      'buyer': false,
    });

    originalMap["id"] = originalMap["_id"];
    originalMap.remove("_id");

    return originalMap;
  }

  Future<void> databaseToFile(
      String filename, List<dynamic> data, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap[key] as List<dynamic>;
      data.forEach((element) {
        Map<String, dynamic> modifiedMap = modifyMap(element);
        userData.add(modifiedMap);
      });
      final newJsonData = jsonEncode({
        key: userData,
      });
      await jsonFile.writeAsString(newJsonData);
      print("FileData : $userData");
      final List<CustomerData> loadedData = [];
      userData.forEach((data) {
        loadedData.add(
          CustomerData(
            id: data['id'],
            name: data['Nm'],
            gstin: data['Gstin'],
            address: data['Addr1'],
            location: data['Loc'],
            stateCode: data['Stcd'],
            pinCode: data['Pin'].toString(),
          ),
        );
      });
      _customers = loadedData;
      notifyListeners();
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Future<void> updateUserDataById(String filename, String id,
      Map<String, dynamic> newData, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap[key] as List<dynamic>;
      final userIndex = userData.indexWhere((user) => user['id'] == id);
      if (userIndex != -1) {
        userData[userIndex].addAll(newData);
        final newJsonData = jsonEncode({
          key: userData,
        });
        await jsonFile.writeAsString(newJsonData);
        final List<CustomerData> loadedData = [];
        userData.forEach((data) {
          loadedData.add(
            CustomerData(
              id: data['id'],
              name: data['Nm'],
              gstin: data['Gstin'],
              address: data['Addr1'],
              location: data['Loc'],
              stateCode: data['Stcd'],
              pinCode: data['Pin'].toString(),
            ),
          );
        });
        _customers = loadedData;
        notifyListeners();
        print("User data with id '$id' updated.");
      } else {
        print("User with id '$id' not found.");
      }
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  String findBuyerById(String id) {
    final data = _customers.firstWhere((element) => element.id == id);
    print("%%%%%%%%%%%% ${data.name}");
    return data.name.toString();
  }

  CustomerData findBuyer(String id) {
    return _customers.firstWhere((element) => element.id == id);
  }

  Future<void> deleteUserDataById(
      String filename, String id, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final userData = jsonDataMap[key] as List<dynamic>;
      for (var entry in userData) {
        if (entry['id'] == id) {
          bool buyerStatus = entry['buyer'];
          if (!buyerStatus) {
            _deletedCustomerId.add(id);
          }
          break; // No need to continue searching once the ID is found
        }
      }
      userData.removeWhere((user) => user['id'] == id);
      final newJsonData = jsonEncode({
        key: userData,
      });
      await jsonFile.writeAsString(newJsonData);
      final List<CustomerData> loadedData = [];
      userData.forEach((data) {
        loadedData.add(
          CustomerData(
            id: data['id'],
            name: data['Nm'],
            gstin: data['Gstin'],
            address: data['Addr1'],
            location: data['Loc'],
            stateCode: data['Stcd'],
            pinCode: data['Pin'].toString(),
          ),
        );
      });
      _customers = loadedData;
      notifyListeners();
      print("User data with id '$id' deleted.");
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }
}
