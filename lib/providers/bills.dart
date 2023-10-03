import 'dart:convert';
import 'dart:io';

import 'package:billing_software/models/Bill/bill_model.dart';
import 'package:billing_software/models/Bill/iteam.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Bills with ChangeNotifier {
  List<BillData> _bills = [];

  String get lastInvoiceNo {
    return _bills.isEmpty ? '0' : _bills.last.no;
  }

  /// remove last item from list
  void removeLastItem() {
    _bills.removeLast();
    notifyListeners();
  }

  /// clear _bills list
  void clearBills() {
    _bills.clear();
    notifyListeners();
  }

  /// i want to check invoice number is already exist or not
  bool isInvoiceNoExist(String invoiceNo) {
    print("Smit $invoiceNo");
    return _bills.any((bill) {
      print("Smit2 ${bill.no}");
      return bill.no == invoiceNo;
    });
  }

  BillData findById(String id) {
    return _bills.firstWhere((bill) => bill.id == id);
  }

  List<BillData> get bills {
    return [..._bills];
  }

  Map<String, dynamic> modifyMap(Map<String, dynamic> originalMap) {
    print("Ninja $originalMap");
    Map<String, dynamic> transformedMap = {
      "Id": originalMap["_id"],
      "No": originalMap["DocDtls"]["No"],
      "BuyerId": originalMap["BuyerDtls"]["id"],
      "OthRefNo": originalMap["RefDtls"]["PrecDocDtls"][0]["OthRefNo"],
      "ItemList": originalMap["ItemList"].map((item) {
        return {
          "IsServc": item["IsServc"],
          "Nm": item["Nm"],
          "SlNo": item["SlNo"],
          "HsnCd": item["HsnCd"],
          "Unit": item["Unit"],
          "Qty": item["Qty"],
          "TotAmt": item["TotAmt"],
          "UnitPrice": item["UnitPrice"],
          "CgstRate": item["CgstRate"],
          "SgstRate": item["SgstRate"],
          "CgstAmt": item["CgstAmt"],
          "SgstAmt": item["SgstAmt"],
          "AssAmt": item["AssAmt"],
          "GstRt": item["GstRt"],
          "TotItemVal": item["TotItemVal"],
        };
      }).toList(),
      "AssVal": int.parse(originalMap["ValDtls"]["AssVal"]["\$numberDecimal"]),
      "TotInvVal":
          double.parse(originalMap["ValDtls"]["TotInvVal"]["\$numberDecimal"]),
      "Distance": originalMap["EwbDtls"]["Distance"],
      "Vehno": originalMap["EwbDtls"]["Vehno"],
      "Nm": originalMap["DispDtls"]["Nm"],
      "Loc": originalMap["DispDtls"]["Loc"],
      "Lr": originalMap["Lr"],
      "IRN": originalMap["IRN"],
      "qr": originalMap["qr"],
      "ackNo": originalMap["ackNo"],
      "ackDt": originalMap["ackDt"] ?? "",
      "signedInv": originalMap["signedInv"],
      "eWayBillNo": originalMap["eWayBillNo"],
      "eWayBillDt": originalMap["eWayBillDt"] ?? "",
      "eWayBillValidDt": originalMap["eWayBillValidDt"] ?? "",
      "isEInv": originalMap["isEInv"],
      "Dt": originalMap["DocDtls"]["Dt"],
      "bill": false,
    };

    return transformedMap;
  }

  Future<void> databaseToFile(
      String filename, List<dynamic> data, String key) async {
    final localDataPath = await _getLocalDataPath();
    final jsonFile = File('$localDataPath/$filename');
    final jsonData = await jsonFile.readAsString();
    final jsonDataMap = json.decode(jsonData);
    final billData = jsonDataMap[key] as List<dynamic>;
    data.forEach((element) {
      Map<String, dynamic> modifiedMap = modifyMap(element);
      billData.add(modifiedMap);
    });
    final newJsonData = jsonEncode({
      key: billData,
    });
    await jsonFile.writeAsString(newJsonData);
    final List<BillData> loadedData = [];

    List<ItemList> itemList = [];
    billData.forEach((element) {
      List itemListData = element['ItemList'];
      itemListData.forEach((item) {
        itemList.add(
          ItemList(
            isServc: item['IsServc'].toString(),
            slNo: item['SlNo'].toString(),
            item: item['Nm'].toString(),
            hsnCode: item['HsnCd'].toString(),
            unit: item['Unit'].toString(),
            qty: item['Qty'],
            totAmt: item['TotAmt'],
            unitPrice: item['UnitPrice'],
            cgstRate: item['CgstRate'],
            sgstRate: item['SgstRate'],
            cgstAmt: double.parse(item['CgstAmt'].toString()),
            sgstAmt: double.parse(item['SgstAmt'].toString()),
            assAmt: item['AssAmt'],
            gstRt: item['GstRt'],
            totItemVal: double.parse(item['TotItemVal'].toString()),
          ),
        );
      });
      loadedData.add(
        BillData(
          id: element['Id'].toString(),
          no: element['No'].toString(),
          buyerId: element['BuyerId'].toString(),
          othRefNo: element['OthRefNo'].toString(),
          itemList: itemList,
          assVal: int.parse(element['AssVal'].toString()),
          totInvVal: double.parse(element['TotInvVal'].toString()),
          distance: int.parse(element['Distance'].toString()),
          vehno: element['Vehno'].toString(),
          nm: element['Nm'].toString(),
          loc: element['Loc'].toString(),
          lr: element['Lr'].toString(),
          eWayBillDt: element['eWayBillDt'].toString(),
          eWayBillNo: element['eWayBillNo'].toString(),
          eWayBillValidDt: element['eWayBillValidDt'].toString(),
          irn: element['IRN'].toString(),
          ackDt: element['ackDt'].toString(),
          ackNo: element['ackNo'].toString(),
          qr: element['qr'].toString(),
          signedInv: element['signedInv'].toString(),
          isEInv: element['isEInv'],
          dt: DateTime.parse(element['Dt']),
        ),
      );
    });
    _bills = loadedData;
    notifyListeners();
  }

  Future<void> fileToList(String filename, String key) async {
    final localDataPath = await _getLocalDataPath();
    final jsonFile = File('$localDataPath/$filename');
    final jsonData = await jsonFile.readAsString();
    final jsonDataMap = json.decode(jsonData);
    final billData = jsonDataMap[key] as List<dynamic>;
    final List<BillData> loadedData = [];

    List<ItemList> itemList = [];
    billData.forEach((element) {
      List itemListData = element['ItemList'];
      itemListData.forEach((item) {
        itemList.add(
          ItemList(
            isServc: item['IsServc'].toString(),
            slNo: item['SlNo'].toString(),
            item: item['Nm'].toString(),
            hsnCode: item['HsnCd'].toString(),
            unit: item['Unit'].toString(),
            qty: item['Qty'],
            totAmt: item['TotAmt'],
            unitPrice: item['UnitPrice'],
            cgstRate: item['CgstRate'],
            sgstRate: item['SgstRate'],
            cgstAmt: double.parse(item['CgstAmt'].toString()),
            sgstAmt: double.parse(item['SgstAmt'].toString()),
            assAmt: item['AssAmt'],
            gstRt: item['GstRt'],
            totItemVal: double.parse(item['TotItemVal'].toString()),
          ),
        );
      });
      loadedData.add(
        BillData(
          id: element['Id'].toString(),
          no: element['No'].toString(),
          buyerId: element['BuyerId'].toString(),
          othRefNo: element['OthRefNo'].toString(),
          itemList: itemList,
          assVal: int.parse(element['AssVal'].toString()),
          totInvVal: double.parse(element['TotInvVal'].toString()),
          distance: int.parse(element['Distance'].toString()),
          vehno: element['Vehno'].toString(),
          nm: element['Nm'].toString(),
          loc: element['Loc'].toString(),
          lr: element['Lr'].toString(),
          eWayBillDt: element['eWayBillDt'].toString(),
          eWayBillNo: element['eWayBillNo'].toString(),
          eWayBillValidDt: element['eWayBillValidDt'].toString(),
          irn: element['IRN'].toString(),
          ackDt: element['ackDt'].toString(),
          ackNo: element['ackNo'].toString(),
          qr: element['qr'].toString(),
          signedInv: element['signedInv'].toString(),
          isEInv: element['isEInv'],
          dt: DateTime.parse(element['Dt']),
        ),
      );
    });
    _bills = loadedData;
    notifyListeners();
  }

  Future<void> updateBuyerIdByIdInFile(String filename, List<dynamic> resData,
      List<dynamic> oldIdList, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      for (var iteam in resData) {
        for (var buyerIteam in jsonDataMap[key]) {
          var condition = false;
          for (var oldId in oldIdList) {
            if (oldId == buyerIteam['BuyerId']) {
              print("Tea");
              print(buyerIteam['BuyerId']);
              print(oldId);
              buyerIteam['BuyerId'] = iteam['id'].toString();
              condition = true;
              break;
            }
          }
          if (condition) break;
        }
      }
      String updatedJsonData = jsonEncode(jsonDataMap);
      print("BuyerIdById $updatedJsonData");
      await jsonFile.writeAsString(updatedJsonData);
      for (var oldId in oldIdList) {
        final billIndex = _bills.indexWhere((bill) => bill.buyerId == oldId);
        for (var item in resData) {
          if (_bills[billIndex].no == item['BillNo']) {
            _bills[billIndex].buyerId = item['id'].toString();
            notifyListeners();
            break;
          }
        }
      }
    } catch (e) {
      print("Error reading or writing file A: $e");
    }
  }

  Future<void> updateBillIdByIdInFile(String filename, List<dynamic> resData,
      List<dynamic> oldIdList, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      for (var iteam in resData) {
        for (var bill in jsonDataMap[key]) {
          if (iteam['BillNo'] == bill['No']) {
            bill['Id'] = iteam['id'].toString();
            bill['bill'] = false;
            break;
          }
        }
      }
      // comment line
      String updatedJsonData = jsonEncode(jsonDataMap);
      print("updated $updatedJsonData");
      await jsonFile.writeAsString(updatedJsonData);
      for (var oldId in oldIdList) {
        final billIndex = _bills.indexWhere((bill) => bill.id == oldId);
        for (var item in resData) {
          if (_bills[billIndex].no == item['BillNo']) {
            _bills[billIndex].id = item['id'].toString();
            notifyListeners();
            break;
          }
        }
      }
    } catch (e) {
      print("Error reading or writing file b: $e");
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
        for (var bill in jsonDataMap[key]) {
          if (id == bill['Id']) {
            bill['bill'] = false;
            break;
          }
        }
      });
      String updatedJsonData = jsonEncode(jsonDataMap);
      print("updated $updatedJsonData");
      await jsonFile.writeAsString(updatedJsonData);
    } catch (e) {
      print("Error reading or writing file: $e");
    }
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
      final billData = jsonDataMap[key] as List<dynamic>;
      billData.add(data);
      final newJsonData = jsonEncode({
        key: billData,
      });
      await jsonFile.writeAsString(newJsonData);
      print("FileData add: $billData");
      notifyListeners();
    } catch (e) {
      print("Error reading or writing: $e");
    }
  }

  Future<void> updateDataToFile(
      String filename, Map<String, dynamic> data, String key, id) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final billData = jsonDataMap[key] as List<dynamic>;
      billData.removeWhere((element) => element['Id'] == id);

      billData.add(data);
      final newJsonData = jsonEncode({
        key: billData,
      });
      await jsonFile.writeAsString(newJsonData);
    } catch (e) {
      print("Error reading or writing in update: $e");
    }
  }

  Future<void> updateBillData(
      String filename, Map<String, dynamic> data, String id, String key) async {
    try {
      final localDataPath = await _getLocalDataPath();
      final jsonFile = File('$localDataPath/$filename');
      final jsonData = await jsonFile.readAsString();
      final jsonDataMap = json.decode(jsonData);
      final billData = jsonDataMap[key] as List<dynamic>;
      billData.removeWhere((element) => element['Id'] == id);

      billData.add(data);
      final newJsonData = jsonEncode({
        key: billData,
      });
      await jsonFile.writeAsString(newJsonData);
      final bill = _bills.firstWhere((bill) => bill.id == id);
      List<ItemList> itemList = [];
      data['ItemList'].forEach((item) {
        itemList.add(
          ItemList(
            isServc: item['IsServc'],
            slNo: item['SlNo'],
            item: item['Nm'],
            hsnCode: item['HsnCd'],
            unit: item['Unit'],
            qty: item['Qty'],
            totAmt: item['TotAmt'],
            unitPrice: item['UnitPrice'],
            cgstRate: item['CgstRate'],
            sgstRate: item['SgstRate'],
            cgstAmt: item['CgstAmt'],
            sgstAmt: item['SgstAmt'],
            assAmt: item['AssAmt'],
            gstRt: item['GstRt'],
            totItemVal: item['TotItemVal'],
          ),
        );
      });
      bill.id = data['Id'];
      bill.no = data['No'];
      bill.buyerId = data['BuyerId'];
      bill.othRefNo = data['OthRefNo'];
      bill.itemList = itemList;
      bill.assVal = data['AssVal'];
      bill.totInvVal = data['TotInvVal'];
      bill.distance = data['Distance'];
      bill.vehno = data['Vehno'];
      bill.nm = data['Nm'];
      bill.loc = data['Loc'];
      bill.lr = data['Lr'];
      bill.dt = DateTime.parse(data['Dt']);
      notifyListeners();
      print("ListData update: $bill");
    } catch (e) {
      print("Error reading or writing: $e");
    }
  }

  Future<void> addNewDataToList(
      String filename, Map<String, dynamic> data, String key) async {
    try {
      final List<BillData> loadedData = _bills;

      List<ItemList> itemList = [];
      data['ItemList'].forEach((item) {
        itemList.add(
          ItemList(
            isServc: item['IsServc'],
            slNo: item['SlNo'],
            item: item['Nm'],
            hsnCode: item['HsnCd'],
            unit: item['Unit'],
            qty: item['Qty'],
            totAmt: item['TotAmt'],
            unitPrice: item['UnitPrice'],
            cgstRate: item['CgstRate'],
            sgstRate: item['SgstRate'],
            cgstAmt: item['CgstAmt'],
            sgstAmt: item['SgstAmt'],
            assAmt: item['AssAmt'],
            gstRt: item['GstRt'],
            totItemVal: item['TotItemVal'],
          ),
        );
      });
      loadedData.add(
        BillData(
          id: data['Id'],
          no: data['No'],
          buyerId: data['BuyerId'],
          othRefNo: data['OthRefNo'],
          itemList: itemList,
          assVal: data['AssVal'],
          totInvVal: data['TotInvVal'],
          distance: data['Distance'],
          vehno: data['Vehno'],
          nm: data['Nm'],
          loc: data['Loc'],
          isEInv: data['isEInv'],
          irn: data['IRN'],
          ackDt: data['ackDt'].toString(),
          ackNo: data['ackNo'].toString(),
          qr: data['qr'].toString(),
          signedInv: data['signedInv'].toString(),
          eWayBillValidDt: data['eWayBillValidDt'],
          eWayBillNo: data['eWayBillNo'],
          eWayBillDt: data['eWayBillDt'],
          lr: data['Lr'],
          dt: DateTime.parse(data['Dt']),
        ),
      );
      _bills = loadedData;
      print("Sikamaru $_bills");
      notifyListeners();
    } catch (e) {
      print("Error reading or writing in List: $e");
    }
  }

  Future<void> updateDataToList(
      String filename, Map<String, dynamic> data, String key, String id) async {
    try {
      print("Golu $data");
      for (var bill in _bills) {
        if (bill.id == id) {
          bill.qr = data['qr'];
          bill.ackDt = data['ackDt'];
          bill.ackNo = data['ackNo'];
          bill.irn = data['IRN'];
          bill.isEInv = true;
          bill.eWayBillNo = data['eWayBillNo'];
          bill.eWayBillDt = data['eWayBillDt'];
          bill.eWayBillValidDt = data['eWayBillValidDt'];
          bill.dt = DateTime.parse(data['Dt']);
          notifyListeners();
        }
        print("Lambo : $bill");
      }
    } catch (e) {
      print("Error reading or writing in List: $e");
    }
  }

  Future<void> fetchDataFromFile(String filename, key) async {
    print(".......................................................");
    final localDataPath = await _getLocalDataPath();
    final jsonFile = File('$localDataPath/$filename');
    final jsonData = await jsonFile.readAsString();
    final jsonDataMap = json.decode(jsonData);
    final billData = jsonDataMap[key] as List<dynamic>;
    final List<BillData> loadedData = [];
    print("Smit $billData");
    billData.forEach((data) {
      print(data['ItemList']);
      List<ItemList> itemList = [];
      data['ItemList'].forEach((item) {
        itemList.add(
          ItemList(
            isServc: item['IsServc'],
            slNo: item['SlNo'],
            item: item['Nm'],
            hsnCode: item['HsnCd'],
            unit: item['Unit'],
            qty: item['Qty'],
            totAmt: item['TotAmt'],
            unitPrice: item['UnitPrice'],
            cgstRate: item['CgstRate'],
            sgstRate: item['SgstRate'],
            cgstAmt: double.parse(item['CgstAmt'].toString()),
            sgstAmt: double.parse(item['SgstAmt'].toString()),
            assAmt: item['AssAmt'],
            gstRt: item['GstRt'],
            totItemVal: double.parse(item['TotItemVal'].toString()),
          ),
        );
      });
      loadedData.add(
        BillData(
          id: data['Id'],
          no: data['No'],
          buyerId: data['BuyerId'],
          othRefNo: data['OthRefNo'],
          itemList: itemList,
          assVal: data['AssVal'],
          totInvVal: data['TotInvVal'],
          distance: data['Distance'],
          vehno: data['Vehno'],
          nm: data['Nm'],
          loc: data['Loc'],
          lr: data['Lr'] ?? '',
          isEInv: data['isEInv'],
          irn: data['IRN'],
          ackDt: data['ackDt'].toString(),
          ackNo: data['ackNo'].toString(),
          qr: data['qr'].toString(),
          signedInv: data['signedInv'].toString(),
          eWayBillValidDt: data['eWayBillValidDt'],
          eWayBillNo: data['eWayBillNo'],
          eWayBillDt: data['eWayBillDt'],
          dt: DateTime.parse(data['Dt']),
        ),
      );
    });
    _bills = loadedData;
    notifyListeners();
    print("FileData : $billData");
  }

  Future<List> getDataFromFile(String filename, key) async {
    print(".......................................................");
    final localDataPath = await _getLocalDataPath();
    final jsonFile = File('$localDataPath/$filename');
    final jsonData = await jsonFile.readAsString();
    final jsonDataMap = json.decode(jsonData);
    final billData = jsonDataMap[key] as List<dynamic>;
    return billData;
  }
}
