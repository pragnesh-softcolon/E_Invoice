import 'dart:convert';
import 'dart:io';

import 'package:billing_software/Files/prefrence_data.dart';
import 'package:billing_software/models/Bill/bill_model.dart';
import 'package:billing_software/models/Bill/iteam.dart';
import 'package:billing_software/models/customer_model.dart';
import 'package:billing_software/models/user.dart';
import 'package:billing_software/network/e-invoice-api.dart';
import 'package:billing_software/providers/bills.dart';
import 'package:billing_software/providers/customers.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:billing_software/widget/generate_pdf.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';
import 'package:billing_software/Files/data.dart' as d;
import 'package:http/http.dart' as http;

class BillHistory extends StatefulWidget {
  final Function(int) setTab;

  const BillHistory(this.setTab, {super.key});

  @override
  State<BillHistory> createState() => _BillHistoryState();
}

class _BillHistoryState extends State<BillHistory> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController clientIdController = TextEditingController();
  TextEditingController clientSecretController = TextEditingController();
  bool _isHovering = false;
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
  final GlobalKey<FormState> _formKey = GlobalKey();
  late Future<List<dynamic>> bills;
  List<dynamic> selectedBill = [];

  @override
  void initState() {
    getUserDetail();
    bills = getBillHistory().then((value) {
      selectedBill = value;
      return value;
    });
    super.initState();
  }

  int ackNo = 0;
  String ackDt = "";
  String signedInvoice = "";
  String qr = "";
  String irn = "";
  int eWayBillNo = 0;
  String eWayBillDt = "";
  String eWayValidDt = "";

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

  Future<List> getBillHistory() {
    return Provider.of<Bills>(context, listen: false)
        .getDataFromFile(Files.bill, Keys.bill);
  }

  Future<void> createEInvoice(var bill) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;

    List<ItemList> itemList = [];

    for (var item in bill['ItemList']) {
      itemList.add(
        ItemList(
          slNo: item['SlNo'],
          isServc: item['IsServc'],
          item: item['Nm'],
          hsnCode: item['HsnCd'],
          qty: item['Qty'],
          unit: item['Unit'],
          unitPrice: item['UnitPrice'],
          totAmt: item['TotAmt'],
          assAmt: item['AssAmt'],
          gstRt: item['GstRt'],
          sgstAmt: item['SgstAmt'],
          cgstAmt: item['CgstAmt'],
          totItemVal: item['TotItemVal'],
          cgstRate: item['CgstRate'],
          sgstRate: item['SgstRate'],
        ),
      );
    }

    BillData billData = BillData(
      id: bill['Id'],
      no: bill['No'],
      buyerId: bill['BuyerId'],
      othRefNo: bill['OthRefNo'],
      itemList: itemList,
      assVal: bill['AssVal'],
      totInvVal: bill['TotInvVal'],
      distance: bill['Distance'],
      vehno: bill['Vehno'],
      nm: bill['Nm'],
      loc: bill['Loc'],
      lr: bill['Lr'],
      irn: bill['IRN'],
      signedInv: bill['signedInv'],
      qr: bill['qr'],
      ackDt: bill['ackDt'],
      ackNo: bill['ackNo'],
      eWayBillNo: bill['eWayBillNo'],
      eWayBillDt: bill['eWayBillDt'],
      eWayBillValidDt: bill['eWayBillValidDt'],
      isEInv: bill['isEInv'],
      dt: DateTime.parse(bill['Dt']),
    );

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
            insetPadding: EdgeInsets.symmetric(horizontal: width * 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Form(
              key: _formKey,
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
                        hintText: 'Enter User Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
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
                        hintText: 'Enter Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
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
                        hintText: 'Enter Client Id',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
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
                        hintText: 'Enter Client Secret',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
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
                              _formKey.currentState!.validate();
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              _formKey.currentState!.save();
                              eInvoiceAuth(
                                  userNameController.text,
                                  passwordController.text,
                                  clientIdController.text,
                                  clientSecretController.text,
                                  billData);
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
                                      clientSecret: clientSecretController.text,
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
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'SAVE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: height * 0.018,
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
      eInvoiceAuth(userName, password, clientId, clientSecret, billData);
    }
  }

  Future<void> eInvoiceAuth(
      String userNm, pass, cId, cSecret, BillData bill) async {
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
      generateIRN(ipAddress, cId, cSecret, userNm, authToken, bill);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> generateIRN(
      String ip, cId, cSecret, userNm, authToken, BillData bill) async {
    CustomerData buyer =
        Provider.of<Customers>(context, listen: false).findBuyer(bill.buyerId);
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
    List<ItemList> data = bill.itemList;
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
        "No": bill.no,
        "Dt": DateFormat('dd/MM/yyyy').format(DateTime.now()),
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
        "Gstin": buyer.gstin,
        "LglNm": buyer.name,
        "Addr1": buyer.address,
        "Loc": buyer.location,
        "Pin": int.parse(buyer.pinCode),
        "Stcd": buyer.stateCode,
        "Pos": buyer.stateCode,
      },
      "DispDtls": {
        "Nm": lglName,
        "Addr1": buyer.address,
        "Loc": loc,
        "Pin": int.parse(pin),
        "Stcd": stcd,
      },
      "ShipDtls": {
        "LglNm": bill.nm,
        "Addr1": buyer.address,
        "Loc": buyer.location,
        "Pin": int.parse(buyer.pinCode),
        "Stcd": buyer.stateCode,
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
            "InvNo": bill.no,
            "InvDt": DateFormat('dd/MM/yyyy').format(DateTime.now()),
            "OthRefNo": "NA"
          }
        ],
      },
      "EwbDtls": {
        "Distance": 0,
        "Vehno": bill.vehno,
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
      String id = DateFormat('dd/MM/yyyy').format(now);
      eWayBill(ip, clientId, clientSecret, userName, authToken, gstin, irn, id,
          bill, buyer, qr, ackNo.toString(), ackDt);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> eWayBill(
      String ip,
      clientId,
      clientSecret,
      userName,
      authToken,
      gstin,
      irn,
      id,
      BillData bill,
      CustomerData buyer,
      String qr,
      ackNo,
      ackDt) async {
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
      "TransName": bill.nm,
      "TransDocDt": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "TransDocNo": bill.no,
      "VehNo": bill.vehno,
      "VehType": "R",
      "ExpShipDtls": {
        "Addr1": buyer.address,
        "Loc": buyer.location,
        "Pin": int.parse(buyer.pinCode),
        "Stcd": buyer.stateCode,
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
    List<ItemList> data = bill.itemList;

    if (response.statusCode == 200) {
      eWayBillNo = jsonData['data']['EwbNo'];
      eWayBillDt = jsonData['data']['EwbDt'];
      eWayValidDt = jsonData['data']['EwbValidTill'];
      int assVal = 0;
      double totInvVal = 0;
      for (var element in data) {
        assVal = assVal + element.assAmt;
        totInvVal = totInvVal + element.totItemVal;
      }
      await Provider.of<Bills>(context, listen: false).updateDataToList(
        Files.bill,
        BillData(
          id: bill.id,
          no: bill.no,
          buyerId: buyer.id,
          othRefNo: "123",
          itemList: data,
          assVal: assVal,
          totInvVal: totInvVal,
          distance: 0,
          vehno: bill.vehno,
          nm: bill.nm,
          loc: bill.loc,
          lr: bill.lr,
          eWayBillDt: eWayBillDt,
          eWayBillNo: eWayBillNo.toString(),
          eWayBillValidDt: eWayValidDt,
          irn: irn,
          signedInv: signedInvoice,
          qr: qr,
          ackNo: ackNo.toString(),
          ackDt: ackDt,
          isEInv: true,
          dt: DateTime.now(),
        ).toJson(),
        Keys.bill,
        bill.id,
      );
      dialog(id, bill, buyer, irn, ackDt, ackNo.toString(), qr,
          eWayBillNo.toString(), eWayBillDt, eWayValidDt);
    } else {
      print(response.reasonPhrase);
    }
  }

  dialog(String id, BillData bill, CustomerData buyer, String irn, ackDt, ackNo,
      qr, eWayBillNo, eWayBillDt, eWayValidDt) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    List<ItemList> data = bill.itemList;
    Map<String, String> selectedCustomerData = {
      "id": buyer.id,
      "name": buyer.name,
      "address": buyer.address,
      "gst": buyer.gstin,
      "stateCode": buyer.stateCode,
      "pinCode": buyer.pinCode,
      "location": buyer.location,
    };
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
                  Navigator.of(context).pop();
                },
              )),
          body: PdfPreview(
            build: (format) => GeneratePdf().generateInvoice(
              bill.id,
              selectedCustomerData,
              selectedBill,
              "Original",
              true,
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
              await Provider.of<Bills>(context, listen: false)
                  .updateDataToFile(
                Files.bill,
                BillData(
                  id: bill.id,
                  no: bill.no,
                  buyerId: bill.buyerId,
                  othRefNo: "123",
                  itemList: data,
                  assVal: assVal,
                  totInvVal: totInvVal,
                  distance: 1,
                  vehno: bill.vehno,
                  nm: bill.nm,
                  loc: bill.loc,
                  lr: bill.lr,
                  eWayBillDt: eWayBillDt,
                  eWayBillNo: eWayBillNo.toString(),
                  eWayBillValidDt: eWayValidDt,
                  irn: irn,
                  signedInv: signedInvoice,
                  qr: qr,
                  ackNo: ackNo.toString(),
                  ackDt: ackDt,
                  isEInv: true,
                  dt: DateTime.now(),
                ).toJson(),
                Keys.bill,
                bill.id,
              )
                  .then(
                (value) {
                  setState(
                    () {
                      bills = getBillHistory().then(
                        (value) {
                          selectedBill = value;
                          return value;
                        },
                      );
                    },
                  );
                },
              );
              Navigator.of(context).pop();
            },
            allowPrinting: true,
            allowSharing: false,
            canDebug: false,
            canChangePageFormat: false,
            canChangeOrientation: false,
            dynamicLayout: false,
          ),
        ),
      ),
    );
  }

  viewInvoice(var bill) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    CustomerData buyer = Provider.of<Customers>(context, listen: false)
        .findBuyer(bill['BuyerId']);
    // print("JOD ${bill.irn} ${bill.ackNo} ${bill.ackDt} ${bill.qr}");
    Map<String, String> selectedCustomerData = {
      "id": buyer.id,
      "name": buyer.name,
      "address": buyer.address,
      "gst": buyer.gstin,
      "stateCode": buyer.stateCode,
      "pinCode": buyer.pinCode,
      "location": buyer.location,
    };
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
                  Navigator.of(context).pop();
                },
              )),
          body: PdfPreview(
            // maxPageWidth: 700,
            build: (format) => GeneratePdf().generateInvoice(
              bill['Id'],
              selectedCustomerData,
              selectedBill,
              "Duplicate",
              bill['isEInv'],
              bill['IRN'],
              bill['signedInv'],
              bill['qr'],
              bill['ackNo'],
              bill['ackDt'],
              bill['eWayBillNo'],
              bill['eWayBillDt'],
              bill['eWayBillValidDt'],
            ),
            onPrinted: (format) {
              Navigator.of(context).pop();
            },
            allowPrinting: true,
            allowSharing: false,
            canDebug: false,
            canChangePageFormat: false,
            canChangeOrientation: false,
            dynamicLayout: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerData =
        Provider.of<Customers>(context, listen: false).customers;
    String getUsernameForId(String id) {
      for (var user in customerData) {
        if (user.id == id) {
          return user.name;
        }
      }
      return "";
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle('Billing Software - Bill-History');
    }

    return FutureBuilder<List<dynamic>>(
      future: bills,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: ListTile(
                  tileColor: Colors.grey.shade100,
                  title: Text("Bill No: ${snapshot.data![index]['No']}"),
                  subtitle: Text(
                      "Buyer Name: ${getUsernameForId(snapshot.data![index]['BuyerId'])}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: snapshot.data![index]['isEInv'] == true
                            ? null
                            : () {
                                widget.setTab(2);
                                PrefrenceData()
                                    .setBillId(snapshot.data![index]['Id']);
                              },
                        child: const Text("Edit"),
                      ),
                      TextButton(
                          onPressed: snapshot.data![index]['isEInv'] == true
                              ? null
                              : () {
                                  createEInvoice(snapshot.data![index]);
                                },
                          child: snapshot.data![index]['IsEInv'] == true
                              ? const Text("Already Created")
                              : const Text("Create e-Invoice")),
                      TextButton(
                          onPressed: () {
                            viewInvoice(snapshot.data![index]);
                          },
                          child: const Text("View")),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );

    // return ListView.builder(
    //   itemCount: bills.length,
    //   shrinkWrap: true,
    //   itemBuilder: (context, index) {
    //     return Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
    //       child: ListTile(
    //         tileColor: Colors.grey.shade100,
    //         title: Text("Bill No: ${bills[index]['No']}"),
    //         subtitle: Text(
    //             "Buyer Name: ${getUsernameForId(bills[index]['BuyerId'])}"),
    //         trailing: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             TextButton(
    //               onPressed: bills[index]['IsEInv']
    //                   ? null
    //                   : () {
    //                       widget.setTab(2);
    //                       PrefrenceData().setBillId(bills[index]['Id']);
    //                     },
    //               child: const Text("Edit"),
    //             ),
    //             TextButton(
    //                 onPressed: bills[index]['IsEInv']
    //                     ? null
    //                     : () {
    //                         createEInvoice(bills[index]);
    //                       },
    //                 child: bills[index]['IsEInv']
    //                     ? const Text("Already Created")
    //                     : const Text("Create e-Invoice")),
    //             TextButton(
    //                 onPressed: () {
    //                   viewInvoice(bills[index]);
    //                 },
    //                 child: const Text("View")),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
