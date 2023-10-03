import 'dart:convert';
import 'dart:io';

import 'package:billing_software/Files/data.dart' as d;
import 'package:billing_software/Files/prefrence_data.dart';
import 'package:billing_software/models/Bill/bill_model.dart';
import 'package:billing_software/models/user.dart';
import 'package:billing_software/network/e-invoice-api.dart';
import 'package:billing_software/providers/bills.dart';
import 'package:billing_software/providers/customers.dart';
import 'package:billing_software/providers/products.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:billing_software/widget/generate_pdf.dart';
import 'package:billing_software/widget/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';

import '../models/Bill/iteam.dart';

class Bill extends StatefulWidget {
  static const routeName = '/Bill';

  const Bill({super.key});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey1 = GlobalKey();
  final GlobalKey<FormState> _formKey2 = GlobalKey();
  bool _isHovering = false;
  bool isEdit = false;
  String selectCustomer = "Select Customer";
  Map<String, String> selectedCustomerData = {};
  Map<String, String> selectedProductData = {};
  String selectProduct = "Select Product";

  String selectedRadio = "Original";

  bool isCheck = false;
  bool isExist = false;

  DateTime invoiceDate = DateTime.now();
  DateTime challanDate = DateTime.now();

  Future<void> _selectDate(
      BuildContext context, DateTime initialDate, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != initialDate) {
      print("object");
      setState(() {
        if (type == "invoice") {
          print("invoice");
          invoiceDate = picked;
        }
        if (type == "challan") {
          print("challan");
          challanDate = picked;
        }
      });
    }
  }

  String formatDate(DateTime date) {
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(date);
  }

  TextEditingController quantityController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController truckNoController = TextEditingController();
  TextEditingController lrNoController = TextEditingController();
  TextEditingController transportNameController = TextEditingController();
  TextEditingController invoiceNoController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController clientIdController = TextEditingController();
  TextEditingController clientSecretController = TextEditingController();

  @override
  void dispose() {
    quantityController.dispose();
    rateController.dispose();
    truckNoController.dispose();
    lrNoController.dispose();
    transportNameController.dispose();
    invoiceNoController.dispose();
    super.dispose();
  }

  String? billId;

  Future<void> fetchBillDetails() async {
    Provider.of<Bills>(context, listen: false)
        .fileToList(Files.bill, Keys.bill);
    billId = await PrefrenceData().getBillId();
    print("fetch Bill Details $billId");
    final billData = Provider.of<Bills>(context, listen: false).bills;
    final customerData =
        Provider.of<Customers>(context, listen: false).customers;
    final billIndex = billData.indexWhere((bill) => bill.id == billId);
    final customerIndex = customerData
        .indexWhere((customer) => customer.id == billData[billIndex].buyerId);
    if (billIndex != -1) {
      final bill = billData[billIndex];
      setState(() {
        isEdit = true;
        invoiceNoController.text = bill.no;
        selectedCustomerData = {
          "id": customerData[customerIndex].id,
          "name": customerData[customerIndex].name,
          "address": customerData[customerIndex].address,
          "gst": customerData[customerIndex].gstin,
          "stateCode": customerData[customerIndex].stateCode,
          "pinCode": customerData[customerIndex].pinCode,
          "location": customerData[customerIndex].location,
        };
        selectCustomer = customerData[customerIndex].name;
        // selectedRadio = bill.buyerId;
        truckNoController.text = bill.vehno;
        lrNoController.text = bill.lr;
        transportNameController.text = bill.nm;
        data = bill.itemList;
      });
    }
  }

  void addProduct(Map<String, String> data) {
    // Get the values from the text fields
    int quantity = int.parse(quantityController.text.toString());
    int rate = int.parse(rateController.text.toString());
    int totAmt = quantity * rate;
    double gstAmt = totAmt * 0.09;

    final itemList = ItemList(
      slNo: data['SlNo']!,
      isServc: "N",
      item: data['name']!,
      hsnCode: data['hsn']!,
      unit: data['unit']!,
      qty: quantity,
      totAmt: totAmt,
      unitPrice: rate,
      cgstRate: 9,
      sgstRate: 9,
      cgstAmt: gstAmt,
      sgstAmt: gstAmt,
      assAmt: totAmt,
      gstRt: 18,
      totItemVal: totAmt + (gstAmt * 2),
    );

    // Add the new customer to the table
    addProductInTable(itemList);
    quantityController.clear();
    rateController.clear();
  }

  List<ItemList> data = [];

  // Add this function to add a customer to the list
  void addProductInTable(ItemList item) {
    setState(() {
      data.add(item);
    });
  }

  // Add this function to delete a customer from the list
  void deleteItem(int index) {
    setState(() {
      data.removeAt(index);
    });
  }

  List<DataRow> buildTableRows() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      ItemList data = entry.value;

      return DataRow(
        cells: [
          DataCell(Text(data.item)),
          DataCell(Text(data.hsnCode)),
          DataCell(Text(data.qty.toString())),
          DataCell(Text(data.unitPrice.toString())),
          DataCell(Text(data.totAmt.toString())),
          DataCell(IconButton(
            onPressed: () {
              /// Alert Dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Item"),
                  content: const Text("Are you sure you want to delete?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteItem(index);
                        Navigator.of(context).pop();
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete),
          )),
        ],
      );
    }).toList();
  }

  int ackNo = 0;
  String ackDt = "";
  String signedInvoice = "";
  String qr = "";
  String irn = "";
  int eWayBillNo = 0;
  String eWayBillDt = "";
  String eWayValidDt = "";

  Future<void> eInvoiceAuth(String userNm, pass, cId, cSecret) async {
    final ipResponse =
        await http.get(Uri.parse('https://api64.ipify.org?format=json'));
    String ipAddress = '';

    if (ipResponse.statusCode == 200) {
      ipAddress = ipResponse.body;
    } else {
      ipAddress = 'Failed to fetch IP address';
    }

    Map<String, String> headers = {
      'username': userNm,
      'password': pass,
      'ip_address': ipAddress.toString(),
      'client_id': cId,
      'client_secret': cSecret,
      'gstin': gstin
    };
    var request = http.Request('GET', Uri.parse(GenerateEInvoice.AUTH));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final res = await response.stream.bytesToString();
    final data = json.decode(res);
    print("Auth Ongoing $data");
    final authToken = data['data']['AuthToken'];

    if (response.statusCode == 200) {
      generateIRN(ipAddress, cId, cSecret, userNm, authToken);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> generateIRN(String ip, cId, cSecret, userNm, authToken) async {
    Map<String, String> headers = {
      'ip_address': ip,
      'client_id': cId,
      'client_secret': cSecret,
      'username': userNm,
      'auth-token': authToken,
      'gstin': gstin,
      'Content-Type': 'application/json'
    };
    int assVal = 0;
    double totInvVal = 0;
    double totSgst = 0;
    double totCgst = 0;
    for (var element in data) {
      assVal = assVal + element.assAmt;
      totInvVal = totInvVal + element.totItemVal;
      totSgst = totSgst + element.sgstAmt;
      totCgst = totCgst + element.cgstAmt;
    }
    List itemList = [];
    for (var item in data) {
      itemList.add({
        'SlNo': item.slNo,
        "IsServc": item.isServc,
        "PrdDesc": item.item,
        "HsnCd": item.hsnCode,
        "BchDtls": {
          "Nm": item.item,
        },
        "Qty": double.parse(item.qty.toString()),
        "Unit": item.unit,
        "UnitPrice": double.parse(item.unitPrice.toString()),
        "TotAmt": double.parse(item.totAmt.toString()),
        "AssAmt": double.parse(item.assAmt.toString()),
        "GstRt": item.gstRt,
        "SgstAmt": item.sgstAmt,
        "CgstAmt": item.cgstAmt,
        "TotItemVal": item.totItemVal,
      });
    }
    var request =
        http.Request('POST', Uri.parse(GenerateEInvoice.GENERATE_IRN));
    request.body = json.encode({
      "Version": "1.1",
      "TranDtls": {
        "TaxSch": "GST",
        "SupTyp": "B2B",
      },
      "DocDtls": {
        "Typ": "INV",
        "No": invoiceNoController.text,
        "Dt": DateFormat('dd/MM/yyyy').format(DateTime.now())
      },
      "SellerDtls": {
        "Gstin": gstin,
        "LglNm": lglName,
        "Addr1": address,
        "Loc": loc,
        "Pin": int.parse(pin),
        "Stcd": stcd,
        "Ph": contact,
      },
      "BuyerDtls": {
        "Gstin": selectedCustomerData['gst'],
        "LglNm": selectedCustomerData['name'],
        "Addr1": selectedCustomerData['address'],
        "Loc": selectedCustomerData['location'],
        "Pin": int.parse(selectedCustomerData['pinCode']!),
        "Stcd": selectedCustomerData['stateCode'],
        "Pos": selectedCustomerData['stateCode'],
      },
      "DispDtls": {
        "Nm": lglName,
        "Addr1": selectedCustomerData['address'],
        "Loc": loc,
        "Pin": int.parse(pin),
        "Stcd": stcd,
      },
      "ShipDtls": {
        "LglNm": transportNameController.text,
        "Addr1": selectedCustomerData['address'],
        "Loc": selectedCustomerData['location'],
        "Pin": int.parse(selectedCustomerData['pinCode']!),
        "Stcd": selectedCustomerData['stateCode'],
      },
      "ItemList": itemList,
      "ValDtls": {
        "AssVal": assVal,
        "TotInvVal": totInvVal,
        "SgstVal": totSgst,
        "CgstVal": totCgst,
      },
      "RefDtls": {
        "InvRm": "TEST",
        "DocPerdDtls": {
          "InvStDt": DateFormat('dd/MM/yyyy').format(DateTime.now()),
          "InvEndDt": DateFormat('dd/MM/yyyy')
              .format(DateTime.now().add(const Duration(days: 30))),
        },
        "PrecDocDtls": [
          {
            "InvNo": invoiceNoController.text,
            "InvDt": DateFormat('dd/MM/yyyy').format(DateTime.now()),
            "OthRefNo": "NA"
          }
        ],
      },
      "EwbDtls": {
        "Distance": 0,
        "Vehno": truckNoController.text,
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    final jsonData = json.decode(res);

    if (response.statusCode == 200) {
      print("======++++>>>> $jsonData");
      ackNo = jsonData['data']['AckNo'];
      ackDt = jsonData['data']['AckDt'];
      irn = jsonData['data']['Irn'];
      qr = jsonData['data']['SignedQRCode'];
      signedInvoice = jsonData['data']['SignedInvoice'];
      DateTime now = DateTime.now();
      String id = DateFormat('ddMMyyHHmmss').format(now);
      eWayBill(ip, clientId, clientSecret, userName, authToken, gstin, irn, id);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> eWayBill(String ip, clientId, clientSecret, userName, authToken,
      gstin, irn, id) async {
    Map<String, String> headers = {
      'ip_address': ip,
      'client_id': clientId,
      'client_secret': clientSecret,
      'username': userName,
      'auth-token': authToken,
      'gstin': gstin,
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse(GenerateEInvoice.GENERATE_EWAYBILL));
    request.body = json.encode({
      "Irn": irn,
      "Distance": 0,
      "TransMode": "1",
      "TransId": "12AWGPV7107B1Z1",
      "TransName": transportNameController.text,
      "TransDocDt": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "TransDocNo": invoiceNoController.text,
      "VehNo": truckNoController.text,
      "VehType": "R",
      "ExpShipDtls": {
        "Addr1": selectedCustomerData['address'],
        "Loc": selectedCustomerData['location'],
        "Pin": int.parse(selectedCustomerData['pinCode']!),
        "Stcd": selectedCustomerData['stateCode'],
      },
      "DispDtls": {
        "Nm": lglName,
        "Addr1": address,
        "Loc": loc,
        "Pin": int.parse(pin),
        "Stcd": stcd
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    final jsonData = json.decode(res);
    int count = 0;
    if (response.statusCode == 200) {
      if (jsonData['status_cd'] == 0 && count < 2) {
        eWayBill(
            ip, clientId, clientSecret, userName, authToken, gstin, irn, id);
        count++;
      }
      print("JOD $jsonData");
      eWayBillNo = jsonData['data']['EwbNo'];
      eWayBillDt = jsonData['data']['EwbDt'];
      eWayValidDt = jsonData['data']['EwbValidTill'];
      int assVal = 0;
      double totInvVal = 0;
      for (var element in data) {
        assVal = assVal + element.assAmt;
        totInvVal = totInvVal + element.totItemVal;
      }
      await Provider.of<Bills>(context, listen: false).addNewDataToList(
        Files.bill,
        BillData(
          id: id,
          no: invoiceNoController.text,
          buyerId: selectedCustomerData['id']!,
          othRefNo: "123",
          itemList: data,
          assVal: assVal,
          totInvVal: totInvVal,
          distance: 0,
          vehno: truckNoController.text,
          nm: transportNameController.text,
          loc: selectedCustomerData['location']!,
          lr: lrNoController.text,
          eWayBillDt: eWayBillDt,
          eWayBillNo: eWayBillNo.toString(),
          eWayBillValidDt: eWayValidDt,
          irn: irn,
          ackDt: ackDt.toString(),
          ackNo: ackNo.toString(),
          qr: qr,
          signedInv: signedInvoice,
          isEInv: isCheck,
          dt: DateTime.now(),
        ).toJson(),
        Keys.bill,
      );
      if (!isEdit) {
        dialog(id);
      } else {
        dialog(billId!);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> printInvoice() async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    if (isCheck) {
      if (userName.isEmpty &&
          password.isEmpty &&
          clientId.isEmpty &&
          clientSecret.isEmpty &&
          userName == '' &&
          password == '' &&
          clientId == '' &&
          clientSecret == '') {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: width * 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Form(
                key: _formKey2,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "e-Invoice Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: userNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          hintText: 'Enter User Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter username!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          hintText: 'Enter Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter password!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: clientIdController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          hintText: 'Enter Client Id',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter client id!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: clientSecretController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          hintText: 'Enter Client Secret',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter client secret!';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 150,
                            height: 35,
                            child: InkWell(
                              onTap: () async {
                                _formKey2.currentState!.validate();
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                _formKey.currentState!.save();
                                eInvoiceAuth(
                                    userNameController.text,
                                    passwordController.text,
                                    clientIdController.text,
                                    clientSecretController.text);
                                await d.data().updateUserDataById(
                                      Files.user,
                                      userId,
                                      UserModel(
                                        token: token,
                                        id: userId,
                                        Gstin: gstin,
                                        LglNm: lglName,
                                        Addr1: address,
                                        Loc: loc,
                                        Pin: int.parse(pin),
                                        Stcd: stcd,
                                        Ph: contact,
                                        accNo: accNo,
                                        bankName: bankName,
                                        branchName: branch,
                                        ifscCode: ifsc,
                                        userName: userNameController.text,
                                        password: passwordController.text,
                                        clientId: clientIdController.text,
                                        clientSecret:
                                            clientSecretController.text,
                                        buyerIds: buyerIds,
                                        productIds: productIds,
                                        billIds: billIds,
                                      ).toMap(),
                                    );
                                Navigator.of(context).pop();
                              },
                              hoverColor: Colors.blue.shade100,
                              onHover: (value) {
                                setState(() {
                                  _isHovering = value;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: const Text(
                                  'SAVE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        eInvoiceAuth(userName, password, clientId, clientSecret);
      }
    } else {
      DateTime now = DateTime.now();
      String id = DateFormat('ddMMyyHHmmss').format(now);
      int assVal = 0;
      double totInvVal = 0;
      for (var element in data) {
        assVal = assVal + element.assAmt;
        totInvVal = totInvVal + element.totItemVal;
      }
      if (!isEdit) {
        await Provider.of<Bills>(context, listen: false).addNewDataToList(
          Files.bill,
          BillData(
            id: id,
            no: invoiceNoController.text,
            buyerId: selectedCustomerData['id']!,
            othRefNo: "123",
            itemList: data,
            assVal: assVal,
            totInvVal: totInvVal,
            distance: 0,
            vehno: truckNoController.text,
            nm: transportNameController.text,
            loc: selectedCustomerData['location']!,
            lr: lrNoController.text,
            signedInv: signedInvoice,
            qr: qr,
            ackNo: ackNo.toString(),
            ackDt: ackDt,
            eWayBillDt: eWayBillDt,
            eWayBillNo: eWayBillNo.toString(),
            eWayBillValidDt: eWayValidDt,
            irn: irn,
            isEInv: isCheck,
            dt: DateTime.now(),
          ).toJson(),
          Keys.bill,
        );
      }
      if (!isEdit) {
        dialog(id);
      } else {
        dialog(billId!);
      }
    }
  }

  dialog(String id) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    int assVal = 0;
    double totInvVal = 0;
    for (var element in data) {
      assVal = assVal + element.assAmt;
      totInvVal = totInvVal + element.totItemVal;
    }
    // BillData billData = BillData(
    //   id: id,
    //   no: invoiceNoController.text,
    //   buyerId: selectedCustomerData['id']!,
    //   othRefNo: "123",
    //   itemList: data,
    //   assVal: assVal,
    //   totInvVal: totInvVal,
    //   distance: 0,
    //   vehno: truckNoController.text,
    //   nm: transportNameController.text,
    //   loc: selectedCustomerData['location']!,
    //   lr: lrNoController.text,
    //   eWayBillDt: eWayBillDt,
    //   eWayBillNo: eWayBillNo.toString(),
    //   eWayBillValidDt: eWayValidDt,
    //   irn: irn,
    //   signedInv: signedInvoice,
    //   qr: qr,
    //   ackNo: ackNo.toString(),
    //   ackDt: ackDt,
    //   isEInv: isCheck,
    //   dt: DateTime.now(),
    // );
    List itmList = [];
    data.forEach((element) {
      itmList.add(
        {
          "IsServc": "N",
          "SlNo": element.slNo,
          "Nm": element.item,
          "HsnCd": element.hsnCode,
          "Unit": element.unit,
          "Qty": element.qty,
          "TotAmt": element.totAmt,
          "UnitPrice": element.unitPrice,
          "CgstRate": element.cgstRate,
          "SgstRate": element.sgstRate,
          "CgstAmt": element.cgstAmt,
          "SgstAmt": element.sgstAmt,
          "AssAmt": element.assAmt,
          "GstRt": element.gstRt,
          "TotItemVal": element.totItemVal,
        },
      );
    });
    List<dynamic> billList = [
      {
        "Id": id,
        "No": invoiceNoController.text,
        "BuyerId": selectedCustomerData['id']!,
        "OthRefNo": "123",
        "ItemList": itmList,
        "AssVal": assVal,
        "TotInvVal": totInvVal,
        "Distance": 0,
        "Vehno": truckNoController.text,
        "Nm": transportNameController.text,
        "Loc": selectedCustomerData['location']!,
        "Lr": lrNoController.text,
        "eWayBillDt": eWayBillDt,
        "eWayBillNo": eWayBillNo.toString(),
        "eWayBillValidDt": eWayValidDt,
        "IRN": irn,
        "signedInv": signedInvoice,
        "qr": qr,
        "ackNo": ackNo.toString(),
        "ackDt": ackDt,
        "isEInv": isCheck,
        "Dt": DateTime.now(),
      }
    ];
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(width * 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text("Invoice Preview"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  /// remove last item from list
                  Provider.of<Bills>(context, listen: false).removeLastItem();
                  Navigator.of(context).pop();
                },
              )),
          body: PdfPreview(
            // maxPageWidth: 700,
            build: (format) => GeneratePdf().generateInvoice(
              id,
              selectedCustomerData,
              billList,
              selectedRadio,
              isCheck,
              irn,
              signedInvoice,
              qr,
              ackNo,
              ackDt,
              eWayBillNo,
              eWayBillDt,
              eWayValidDt,
            ),
            onPrinted: (format) async {
              int assVal = 0;
              double totInvVal = 0;
              for (var element in data) {
                assVal = assVal + element.assAmt;
                totInvVal = totInvVal + element.totItemVal;
              }
              if (!isEdit) {
                await Provider.of<Bills>(context, listen: false)
                    .addNewDataToFile(
                  Files.bill,
                  BillData(
                    id: id,
                    no: invoiceNoController.text,
                    buyerId: selectedCustomerData['id']!,
                    othRefNo: "123",
                    itemList: data,
                    assVal: assVal,
                    totInvVal: totInvVal,
                    distance: 0,
                    vehno: truckNoController.text,
                    nm: transportNameController.text,
                    loc: selectedCustomerData['location']!,
                    lr: lrNoController.text,
                    eWayBillDt: eWayBillDt,
                    eWayBillNo: eWayBillNo.toString(),
                    eWayBillValidDt: eWayValidDt,
                    irn: irn,
                    signedInv: signedInvoice,
                    qr: qr,
                    ackNo: ackNo.toString(),
                    ackDt: ackDt,
                    isEInv: isCheck,
                    dt: DateTime.now(),
                  ).toJson(),
                  Keys.bill,
                );
              } else {
                await Provider.of<Bills>(context, listen: false).updateBillData(
                  Files.bill,
                  BillData(
                    id: billId!,
                    no: invoiceNoController.text,
                    buyerId: selectedCustomerData['id']!,
                    othRefNo: "123",
                    itemList: data,
                    assVal: assVal,
                    totInvVal: totInvVal,
                    distance: 0,
                    vehno: truckNoController.text,
                    nm: transportNameController.text,
                    loc: selectedCustomerData['location']!,
                    lr: lrNoController.text,
                    eWayBillDt: eWayBillDt,
                    eWayBillNo: eWayBillNo.toString(),
                    eWayBillValidDt: eWayValidDt,
                    signedInv: signedInvoice,
                    qr: qr,
                    ackNo: ackNo.toString(),
                    ackDt: ackDt,
                    irn: irn,
                    isEInv: isCheck,
                    dt: DateTime.now(),
                  ).toJson(),
                  billId!,
                  Keys.bill,
                );
              }
              transportNameController.clear();
              lrNoController.clear();
              truckNoController.clear();
              data.clear();
              SharedPreferences.getInstance().then((value) {
                value.clear();
              });
              setState(() {
                isEdit = false;
              });
              final lastInvoiceNo =
                  Provider.of<Bills>(context, listen: false).lastInvoiceNo;
              print("=======2$lastInvoiceNo");
              String currentInvoiceNo = getNextValue(lastInvoiceNo);
              invoiceNoController.text = currentInvoiceNo;
              Navigator.of(context).pop();
            },
            allowPrinting: true,
            allowSharing: false,
            canDebug: false,
            canChangePageFormat: false,
            canChangeOrientation: false,
            dynamicLayout: true,
          ),
        ),
      ),
    );
  }

  String getNextValue(String input) {
    if (RegExp(r'[A-Za-z]').hasMatch(input)) {
      // If the input contains letters (alphanumeric), increment the numeric part
      String numericPart = input.replaceAll(RegExp(r'[^0-9]'), '');
      int numericValue = int.parse(numericPart);
      int nextNumericValue = numericValue + 1;
      return input.replaceAll(numericPart, nextNumericValue.toString());
    } else if (RegExp(r'^[0-9]+$').hasMatch(input)) {
      // If the input contains only digits, increment the numeric value
      int numericValue = int.parse(input);
      int nextNumericValue = numericValue + 1;
      return nextNumericValue.toString();
    } else {
      // Invalid input
      return "Invalid input";
    }
  }

  @override
  void initState() {
    /// check billId key is exist or not in prefrence
    SharedPreferences.getInstance().then((value) {
      if (value.containsKey("billId")) {
        fetchBillDetails();
      } else {
        final lastInvoiceNo =
            Provider.of<Bills>(context, listen: false).lastInvoiceNo;
        print("========$lastInvoiceNo");
        String currentInvoiceNo = getNextValue(lastInvoiceNo);
        invoiceNoController.text = currentInvoiceNo;
      }
    });
    getUserDetail();
    super.initState();
  }

  String token = '';
  String gstin = '';
  String lglName = '';
  String address = '';
  String loc = '';
  String pin = '';
  String stcd = '';
  String contact = '';
  String bankName = '';
  String branch = '';
  String accNo = '';
  String ifsc = '';
  String userId = '';
  String userName = '';
  String password = '';
  String clientId = '';
  String clientSecret = '';
  List<dynamic> buyerIds = [];
  List<dynamic> productIds = [];
  List<dynamic> billIds = [];

  Future<void> getUserDetail() async {
    Map<String, dynamic> userData =
        await d.data().fetchDataFromFile(Files.user, Keys.user);
    token = userData['token'];
    buyerIds = userData['buyerIds'];
    productIds = userData['productIds'];
    billIds = userData['billIds'];
    gstin = userData['Gstin'];
    lglName = userData['LglNm'];
    address = userData['Addr1'];
    loc = userData['Loc'];
    pin = userData['Pin'].toString();
    stcd = userData['Stcd'];
    contact = userData['Ph'];
    bankName = userData['bankName'];
    branch = userData['branchName'];
    accNo = userData['accNo'];
    ifsc = userData['ifscCode'];
    userId = userData['id'];
    userName = userData['userName'];
    password = userData['password'];
    clientId = userData['clientId'];
    clientSecret = userData['clientSecret'];
  }

  @override
  Widget build(BuildContext context) {
    final customerList =
        Provider.of<Customers>(context, listen: false).customers;
    final productList = Provider.of<Products>(context, listen: false).products;
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle('Billing Software - Bill');
    }
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
            child: Wrap(
              spacing: size.width * 0.07,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: const Text(
                          "Invoice No. :",
                          style: TextStyle(
                            fontSize: 15.6,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    SizedBox(
                      width: 210,
                      child: TextFormField(
                        enabled: !isEdit,
                        controller: invoiceNoController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          hintText: 'Enter Invoice No',
                          errorText: isExist && !isEdit
                              ? "Invoice No already exist!"
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (Provider.of<Bills>(context, listen: false)
                              .isInvoiceNoExist(value)) {
                            setState(() {
                              isExist = true;
                            });
                          } else {
                            setState(() {
                              isExist = false;
                            });
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Invoice No!';
                          }
                          if (Provider.of<Bills>(context, listen: false)
                                  .isInvoiceNoExist(value) &&
                              !isEdit) {
                            return 'Invoice No already exist!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 320,
                  height: 33,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: DropdownButton(
                    underline: Container(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    borderRadius: BorderRadius.circular(0),
                    hint: Text(
                      selectCustomer,
                      style: selectCustomer == "Select Customer"
                          ? null
                          : const TextStyle(color: Colors.black),
                    ),
                    isExpanded: true,
                    items: !isEdit
                        ? customerList.map((options) {
                            return DropdownMenuItem(
                              value: options,
                              child: Text(options.name),
                            );
                          }).toList()
                        : null,
                    onChanged: (newValue) {
                      setState(() {
                        selectCustomer = newValue!.name;
                        selectedCustomerData = {
                          "id": newValue.id,
                          "name": newValue.name,
                          "address": newValue.address,
                          "gst": newValue.gstin,
                          "stateCode": newValue.stateCode,
                          "pinCode": newValue.pinCode,
                          "location": newValue.location,
                        };
                      });
                      print(selectedCustomerData);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
            child: const Text(
              "Transport Detail",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
            child: Wrap(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: Container(
                        width: 150,
                        height: 30,
                        alignment: Alignment.center,
                        child: const Text(
                          "Name of Transport :",
                          style: TextStyle(
                            fontSize: 15.6,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    SizedBox(
                      width: 210,
                      child: TextFormField(
                        enabled: !isEdit,
                        controller: transportNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          hintText: 'Enter Transport Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Transport Name!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(width: size.width * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: Container(
                        height: 30,
                        // margin: const EdgeInsets.only(top: 5),
                        alignment: Alignment.center,
                        child: const Text(
                          "L.R No :",
                          style: TextStyle(
                            fontSize: 15.6,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    SizedBox(
                      width: 180,
                      child: TextFormField(
                        enabled: !isEdit,
                        controller: lrNoController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          hintText: 'Enter L.R No',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter L.R No!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(width: size.width * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: Container(
                        height: 30,
                        // margin: const EdgeInsets.only(top: 15),
                        alignment: Alignment.center,
                        child: const Text(
                          "Truck No :",
                          style: TextStyle(
                            fontSize: 15.6,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      width: 180,
                      child: TextFormField(
                        enabled: !isEdit,
                        controller: truckNoController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          hintText: 'Enter Truck No',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Truck No!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
            child: const Text(
              "Product Detail",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Form(
            key: _formKey1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
              child: Wrap(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 320,
                    height: 33,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: DropdownButton(
                      underline: Container(),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      borderRadius: BorderRadius.circular(0),
                      hint: Text(
                        selectProduct,
                        style: selectProduct == "Select Product"
                            ? null
                            : const TextStyle(color: Colors.black),
                      ),
                      isExpanded: true,
                      items: productList.map((options) {
                        return DropdownMenuItem(
                          value: options,
                          child: Text(options.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectProduct = newValue!.name;
                          selectedProductData = {
                            "id": newValue.id,
                            "name": newValue.name,
                            "hsn": newValue.hsnCode,
                            "unit": newValue.unit,
                            'SlNo': newValue.slNo,
                          };
                        });
                      },
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  IntrinsicWidth(
                    child: Container(
                      height: 30,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      child: const Text(
                        "Qty :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.01),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 150,
                    child: TextFormField(
                      controller: quantityController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: size.height * 0.01,
                        ),
                        hintText: 'Enter Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Quantity!';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  IntrinsicWidth(
                    child: Container(
                      height: 30,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      child: const Text(
                        "Rate :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.01),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 150,
                    child: TextFormField(
                      controller: rateController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: size.height * 0.01,
                        ),
                        hintText: 'Enter Rate',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Rate!';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: size.width * 0.025),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 180,
                    height: 32,
                    child: InkWell(
                      onTap: () {
                        if (!_formKey1.currentState!.validate()) {
                          return;
                        }
                        if (selectedProductData.isEmpty) {
                          ToastMessage().showToast(
                              "Please select product!", context, false);
                          return;
                        }
                        _formKey1.currentState!.save();
                        addProduct(
                            selectedProductData); // Call the saveCustomer function here
                      },
                      hoverColor: Colors.blue.shade50,
                      onHover: (value) {
                        setState(() {
                          _isHovering = value;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0, // Border width
                          ),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: const Text(
                          'ADD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isCheck,
                  onChanged: (value) {
                    setState(() {
                      isCheck = value!;
                    });
                  },
                ),
                const Text(
                  "e-Invoice",
                  style: TextStyle(
                    fontSize: 15.6,
                  ),
                ),
                const SizedBox(width: 30),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    height: 30,
                    child: InkWell(
                      onTap: () {
                        _formKey.currentState!.validate();
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        if (data.isEmpty) {
                          ToastMessage().showToast(
                              "Please add products!", context, false);
                          return;
                        }
                        if (selectedCustomerData.isEmpty) {
                          ToastMessage().showToast(
                              "Please select customer!", context, false);
                          return;
                        }
                        _formKey.currentState!.save();
                        printInvoice();
                      },
                      hoverColor: Colors.blue.shade100,
                      onHover: (value) {
                        setState(() {
                          _isHovering = value;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: const Text(
                          'PRINT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Wrap the table with Expanded and SingleChildScrollView
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Product Name")),
                  DataColumn(label: Text("HSN Code")),
                  DataColumn(label: Text("Quantity")),
                  DataColumn(label: Text("Rate")),
                  DataColumn(label: Text("Amount")),
                  DataColumn(label: Text("Delete")),
                ],
                rows: buildTableRows(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
