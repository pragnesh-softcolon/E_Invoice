import 'dart:convert';

import 'package:billing_software/Files/data.dart';
import 'package:billing_software/network/apis.dart';
import 'package:billing_software/providers/bills.dart';
import 'package:billing_software/providers/customers.dart';
import 'package:billing_software/providers/products.dart';
import 'package:billing_software/screens/bill.dart';
import 'package:billing_software/screens/bill_history.dart';
import 'package:billing_software/screens/customer.dart';
import 'package:billing_software/screens/login.dart';
import 'package:billing_software/screens/product.dart';
import 'package:billing_software/screens/user_profile.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:billing_software/widget/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home-page';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

int _tab = 0;

class _HomePageState extends State<HomePage> {
  bool isSync = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setTab(0);
  }

  void setTab(int tab) {
    setState(() {
      _tab = tab;
    });
    if (tab != 2) {
      SharedPreferences.getInstance().then((value) {
        value.clear();
      });
    }
    print(_tab);
  }

  Future<void> syncUser(String token) async {
    final userData = await data().fetchDataFromFile(Files.user, Keys.user);
    if (userData.isEmpty) {
      setState(() {
        isSync = false;
      });
      return;
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('POST', Uri.parse(Apis.SYNC_USER));
    request.body = json.encode({"userDetails": userData});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String res = await response.stream.bytesToString();
    print(res);
    if (response.statusCode == 200) {
      final userData = json.decode(res);
      final List userDataList = userData['data']['rows'];
      print("Sahil Itachi $userDataList");
      String userId = userDataList[0]['_id'];
      data().updateUserDataById(Files.user, userId, userDataList[0]);
      setState(() {
        isSync = false;
      });
    } else {
      setState(() {
        isSync = false;
      });
      print(response.reasonPhrase);
    }
  }

  Future<void> syncBill(String token) async {
    final billData = await data().fetchDataFromFile(Files.bill, Keys.bill);
    billData.removeWhere((element) => element['bill'] == false);
    final billIdList = billData.map((e) => e['Id']).toList();
    print("Sakura $billData");
    if (billData.isEmpty) {
      syncUser(token);
      return;
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('POST', Uri.parse(Apis.SYNC_BILL));
    request.body = json.encode({"bill": billData});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String res = await response.stream.bytesToString();
    print("Akamaru $res");
    if (response.statusCode == 200) {
      final data = json.decode(res);
      final List billResData = data['data']['bills'];
      final List updatedBillResData = data['data']['updatedbills'];
      if (billResData.isNotEmpty) {
        Provider.of<Bills>(context, listen: false).updateBillIdByIdInFile(
            Files.bill, billResData, billIdList, Keys.bill);
      }
      if (updatedBillResData.isNotEmpty) {
        Provider.of<Bills>(context, listen: false)
            .updateStatusByIdInFile(Files.bill, updatedBillResData, Keys.bill);
      }
      setState(() {
        isSync = false;
      });
      syncUser(token);
    } else {
      setState(() {
        isSync = false;
      });
      print(response.reasonPhrase);
    }
  }

  Future<void> syncProduct(String token) async {
    final productData =
        await data().fetchDataFromFile(Files.product, Keys.product);
    productData.removeWhere((element) => element['product'] == false);
    print("Sasuke $productData");
    if (productData.isEmpty) {
      syncBill(token);
      return;
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('POST', Uri.parse(Apis.SYNC_PRODUCT));
    request.body = json.encode({"product": productData});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String res = await response.stream.bytesToString();
    print("+++++++++$res");

    if (response.statusCode == 200) {
      final data = json.decode(res);
      final List productResData = data['data']['NewData'];
      final List updatedResId = data['data']['UpdatedData'];
      if (productResData.isNotEmpty) {
        Provider.of<Products>(context, listen: false)
            .updateIdBySlNoInFile(Files.product, productResData, Keys.product);
      }
      if (updatedResId.isNotEmpty) {
        Provider.of<Products>(context, listen: false)
            .updateStatusByIdInFile(Files.product, updatedResId, Keys.product);
      }
      syncBill(token);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> syncBuyer() async {
    String? token = await data().retrieveAccessToken(Files.user);
    final buyerData =
        await data().fetchDataFromFile(Files.customer, Keys.customer);
    buyerData.removeWhere((element) => element['buyer'] == false);
    final buyerIdList = buyerData.map((e) => e['id']).toList();
    print("Naruto $buyerIdList");
    if (buyerData.isEmpty) {
      syncProduct(token!);
      return;
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('POST', Uri.parse(Apis.SYNC_BUYER));
    request.body = json.encode({
      "buyer": buyerData,
    });
    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    print("================$res");
    if (response.statusCode == 200) {
      final data = json.decode(res);
      final List buyerResData = data['data']['NewData'];
      final List updatedResId = data['data']['UpdatedData'];
      print(buyerResData);
      if (buyerResData.isNotEmpty) {
        Provider.of<Customers>(context, listen: false)
            .updateIdByGstinInFile(Files.customer, buyerResData, Keys.customer);
        Provider.of<Bills>(context, listen: false).updateBuyerIdByIdInFile(
            Files.bill, buyerResData, buyerIdList, Keys.bill);
      }
      if (updatedResId.isNotEmpty) {
        Provider.of<Customers>(context, listen: false).updateStatusByIdInFile(
            Files.customer, updatedResId, Keys.customer);
      }
      syncProduct(token!);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> syncDeleteBuyer() async {
    String? token = await data().retrieveAccessToken(Files.user);
    List buyerIds =
        Provider.of<Customers>(context, listen: false).deletedCustomerId;
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('POST', Uri.parse(Apis.DELETE_BUYERS));
    request.body = json.encode({
      "buyerIds": buyerIds,
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> syncDeleteProduct() async {
    String? token = await data().retrieveAccessToken(Files.user);
    List productIds =
        Provider.of<Products>(context, listen: false).deletedItemId;
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('POST', Uri.parse(Apis.DELETE_PRODUCTS));
    request.body = json.encode({
      "productIds": productIds,
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final res = await response.stream.bytesToString();
    print("======> $res ======> ${response.statusCode}");
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<bool> checkInternetConnectivity() async {
    final InternetConnectionStatus status =
        await InternetConnectionChecker().connectionStatus;

    return status == InternetConnectionStatus.connected;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Row(
            children: [
              TextButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      if (_tab == 0) {
                        return const BorderSide(
                          color: Colors.blue,
                        ); // Replace this with your desired hover color
                      }
                      return null;
                    },
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (_tab == 0) {
                        return Colors.blue
                            .shade50; // Replace this with your desired selected color
                      }
                      return Colors
                          .transparent; // No background color for other states
                    },
                  ),
                ),
                onPressed: () {
                  setTab(0);
                },
                child: const Text("Customers",
                    style: TextStyle(
                      color: AppColors.black,
                    )),
              ),
              TextButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      if (_tab == 1) {
                        return const BorderSide(
                          color: Colors.blue,
                        ); // Replace this with your desired hover color
                      }
                      return null;
                    },
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (_tab == 1) {
                        return Colors.blue
                            .shade50; // Replace this with your desired selected color
                      }
                      return Colors
                          .transparent; // No background color for other states
                    },
                  ),
                ),
                onPressed: () {
                  setTab(1);
                },
                child: const Text("Products",
                    style: TextStyle(
                      color: AppColors.black,
                    )),
              ),
              TextButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      if (_tab == 2) {
                        return const BorderSide(
                          color: Colors.blue,
                        ); // Replace this with your desired hover color
                      }
                      return null;
                    },
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (_tab == 2) {
                        return Colors.blue
                            .shade50; // Replace this with your desired selected color
                      }
                      return Colors
                          .transparent; // No background color for other states
                    },
                  ),
                ),
                onPressed: () {
                  setTab(2);
                },
                child: const Text("Bill",
                    style: TextStyle(
                      color: AppColors.black,
                    )),
              ),
              TextButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      if (_tab == 3) {
                        return const BorderSide(
                          color: Colors.blue,
                        ); // Replace this with your desired hover color
                      }
                      return null;
                    },
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (_tab == 3) {
                        return Colors.blue
                            .shade50; // Replace this with your desired selected color
                      }
                      return Colors
                          .transparent; // No background color for other states
                    },
                  ),
                ),
                onPressed: () {
                  setTab(3);
                },
                child: const Text("Profile",
                    style: TextStyle(
                      color: AppColors.black,
                    )),
              ),
              TextButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      if (_tab == 4) {
                        return const BorderSide(
                          color: Colors.blue,
                        ); // Replace this with your desired hover color
                      }
                      return null;
                    },
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (_tab == 4) {
                        return Colors.blue
                            .shade50; // Replace this with your desired selected color
                      }
                      return Colors
                          .transparent; // No background color for other states
                    },
                  ),
                ),
                onPressed: () {
                  setTab(4);
                },
                child: const Text("Bill-History",
                    style: TextStyle(
                      color: AppColors.black,
                    )),
              ),
              TextButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      if (_tab == 5) {
                        return const BorderSide(
                          color: Colors.blue,
                        ); // Replace this with your desired hover color
                      }
                      return null;
                    },
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (_tab == 5) {
                        return Colors.blue
                            .shade50; // Replace this with your desired selected color
                      }
                      return Colors
                          .transparent; // No background color for other states
                    },
                  ),
                ),
                onPressed: () {
                  try {
                    /// Alert dialog to confirm logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () async {
                              bool result = await data().deleteFiles(context);
                              if (result) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    SignIn.routeName, (route) => false);
                                return;
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print("Error clearing preferences: $e");
                  }
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: AppColors.black,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      if (states.contains(MaterialState.hovered)) {
                        return const BorderSide(
                          color: Colors.blue,
                        ); // Replace this with your desired hover color
                      }
                      return null;
                    },
                  ),
                ),
                onPressed: isSync
                    ? null
                    : () async {
                        bool isConnected = await checkInternetConnectivity();
                        if (!isConnected) {
                          ToastMessage().showToast(
                              "Please check your internet connection",
                              context,
                              false);
                          return;
                        }
                        setState(() {
                          isSync = true;
                        });

                        /// Sync data to server
                        syncBuyer();
                        syncDeleteBuyer();
                        syncDeleteProduct();
                      },
                child: Text(
                  isSync ? "Syncing" : "Sync",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSync
                        ? AppColors.black.withOpacity(.5)
                        : AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tab == 0
                ? const SingleChildScrollView(child: Customer())
                : Container(),
            _tab == 1
                ? const SingleChildScrollView(child: Product())
                : Container(),
            _tab == 2
                ? const SingleChildScrollView(child: Bill())
                : Container(),
            _tab == 3
                ? const SingleChildScrollView(child: UserProfile())
                : Container(),
            _tab == 4
                ? SingleChildScrollView(child: BillHistory(setTab))
                : Container(),
          ],
        ),
      ),
    );
  }
}
