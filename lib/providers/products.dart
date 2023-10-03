import 'dart:convert';
import 'dart:io';

import 'package:billing_software/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Products with ChangeNotifier {
  List<ProductData> _products = [];

  List<String> _deletedItemId = [];

  /// clear _products list
  void clearProducts() {
    _products.clear();
    notifyListeners();
  }

  Future<void> updateStatusByIdInFile(
      String filename, List<dynamic> resData, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      resData.forEach((id) {
        for (var prodItem in jsonDataMap[key]) {
          if (id == prodItem['id']) {
            prodItem['product'] = false;
            break;
          }
        }
      });
      String updatedJsonData = jsonEncode(jsonDataMap);
      print("updated $updatedJsonData");
      await jsonFile.writeAsString(updatedJsonData);
      final newData = jsonDataMap[key] as List<dynamic>;
      final List<ProductData> loadedData = [];
      newData.forEach((data) {
        loadedData.add(
          ProductData(
            id: data['id'],
            name: data['BchDtls']['Nm'],
            hsnCode: data['HsnCd'],
            unit: data['Unit'],
            slNo: data['SlNo'],
          ),
        );
      });
      _products = loadedData;
      notifyListeners();
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Future<void> updateIdBySlNoInFile(
      String filename, List<dynamic> resData, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      for (var item in resData) {
        for (var productItem in jsonDataMap[key]) {
          if (item['SlNo'] == productItem['SlNo']) {
            print("-------------");
            print(item['SlNo']);
            productItem['id'] = item['id'];
            productItem['product'] = false;
            break;
          }
        }
      }
      String updatedJsonData = jsonEncode(jsonDataMap);
      print("updated $updatedJsonData");
      await jsonFile.writeAsString(updatedJsonData);
      final newData = jsonDataMap[key] as List<dynamic>;
      final List<ProductData> loadedData = [];
      newData.forEach((data) {
        loadedData.add(
          ProductData(
            id: data['id'],
            name: data['BchDtls']['Nm'],
            hsnCode: data['HsnCd'],
            unit: data['Unit'],
            slNo: data['SlNo'],
          ),
        );
      });
      _products = loadedData;
      notifyListeners();
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Map<String, dynamic> modifyMap(Map<String, dynamic> originalMap) {
    originalMap.remove("__v");
    originalMap.remove("createdAt");
    originalMap.remove("updatedAt");
    originalMap.addAll({
      'product': false,
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
      final prodData = jsonDataMap[key] as List<dynamic>;
      data.forEach((element) {
        Map<String, dynamic> modifiedMap = modifyMap(element);
        prodData.add(modifiedMap);
      });
      final newJsonData = jsonEncode({
        key: prodData,
      });
      await jsonFile.writeAsString(newJsonData);
      print("FileData : $prodData");
      final List<ProductData> loadedData = [];
      prodData.forEach((data) {
        loadedData.add(
          ProductData(
            id: data['id'],
            name: data['BchDtls']['Nm'],
            hsnCode: data['HsnCd'],
            unit: data['Unit'],
            slNo: data['SlNo'],
          ),
        );
      });
      _products = loadedData;
      notifyListeners();
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  /// get slNo of last customer
  String getSlNo() {
    if (_products.isEmpty) {
      return '0';
    }
    return _products.last.slNo;
  }

  ProductData findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<ProductData> get products {
    return [..._products];
  }

  List<String> get deletedItemId {
    return [..._deletedItemId];
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
      final prodData = jsonDataMap[key] as List<dynamic>;
      prodData.add(data);
      final newJsonData = jsonEncode({
        key: prodData,
      });
      await jsonFile.writeAsString(newJsonData);
      print("FileData : $prodData");
      final List<ProductData> loadedData = [];
      prodData.forEach((data) {
        loadedData.add(
          ProductData(
            id: data['id'],
            name: data['BchDtls']['Nm'],
            hsnCode: data['HsnCd'],
            unit: data['Unit'],
            slNo: data['SlNo'],
          ),
        );
      });
      _products = loadedData;
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
      final prodData = jsonDataMap[key] as List<dynamic>;
      final List<ProductData> loadedData = [];
      prodData.forEach((data) {
        loadedData.add(
          ProductData(
            id: data['id'],
            name: data['BchDtls']['Nm'],
            hsnCode: data['HsnCd'],
            unit: data['Unit'],
            slNo: data['SlNo'],
          ),
        );
      });
      _products = loadedData;
      notifyListeners();
      print("FileData : $prodData");
    } catch (e) {
      print("Error reading file: $e");
    }
  }

  Future<void> updateProdDataById(String filename, String id,
      Map<String, dynamic> newData, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final prodData = jsonDataMap[key] as List<dynamic>;
      final userIndex = prodData.indexWhere((user) => user['id'] == id);
      if (userIndex != -1) {
        prodData[userIndex].addAll(newData);
        final newJsonData = jsonEncode({
          key: prodData,
        });
        await jsonFile.writeAsString(newJsonData);
        final List<ProductData> loadedData = [];
        prodData.forEach((data) {
          loadedData.add(
            ProductData(
              id: data['id'],
              name: data['BchDtls']['Nm'],
              hsnCode: data['HsnCd'],
              unit: data['Unit'],
              slNo: data['SlNo'],
            ),
          );
        });
        _products = loadedData;
        notifyListeners();
        print("User data with id '$id' updated.");
      } else {
        print("User with id '$id' not found.");
      }
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }

  Future<void> deleteProdDataById(
      String filename, String id, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final prodData = jsonDataMap[key] as List<dynamic>;
      for (var entry in prodData) {
        if (entry['id'] == id) {
          bool prodStatus = entry['product'];
          if (!prodStatus) {
            _deletedItemId.add(id);
          }
          break; // No need to continue searching once the ID is found
        }
      }
      prodData.removeWhere((user) => user['id'] == id);
      final newJsonData = jsonEncode({
        key: prodData,
      });
      await jsonFile.writeAsString(newJsonData);
      final List<ProductData> loadedData = [];
      prodData.forEach((data) {
        loadedData.add(
          ProductData(
            id: data['id'],
            name: data['BchDtls']['Nm'],
            hsnCode: data['HsnCd'],
            unit: data['Unit'],
            slNo: data['SlNo'],
          ),
        );
      });
      _products = loadedData;
      notifyListeners();
      print("User data with id '$id' deleted.");
    } catch (e) {
      print("Error reading or writing file: $e");
    }
  }
}
