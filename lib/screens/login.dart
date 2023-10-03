import 'dart:convert';
import 'dart:io';
import 'package:billing_software/Files/data.dart';
import 'package:billing_software/models/user.dart';
import 'package:billing_software/network/apis.dart';
import 'package:billing_software/providers/bills.dart';
import 'package:billing_software/providers/customers.dart';
import 'package:billing_software/providers/products.dart';
import 'package:billing_software/screens/home_page.dart';
import 'package:billing_software/screens/sign_up.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {
  static const routeName = '/sign-in';

  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey1 = GlobalKey();

  TextEditingController numberController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  bool sendOtp = false;

  String accNo = '';
  String clientSecret = '';
  String clientId = '';
  String password = '';
  String userName = '';
  String ifscCode = '';
  String branchName = '';
  String bankName = '';

  Future<void> verifyOtp() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(Apis.VALIDATE_OTP));
    request.body = json.encode({
      "Ph": numberController.text,
      "otp": otpController.text,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    print("GARA $res");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(res);
      String token = jsonMap['data']['access_token'];
      String _id = jsonMap['data']['userDetails']['_id'];
      String Gstin = jsonMap['data']['userDetails']['Gstin'];
      String LglNm = jsonMap['data']['userDetails']['LglNm'];
      String Addr1 = jsonMap['data']['userDetails']['Addr1'];
      String Loc = jsonMap['data']['userDetails']['Loc'];
      int Pin = jsonMap['data']['userDetails']['Pin'];
      String Stcd = jsonMap['data']['userDetails']['Stcd'];
      accNo = jsonMap['data']['userDetails']['acNo'];
      bankName = jsonMap['data']['userDetails']['bankName'];
      branchName = jsonMap['data']['userDetails']['branch'];
      ifscCode = jsonMap['data']['userDetails']['IFSC'];
      userName = jsonMap['data']['userDetails']['username'];
      password = jsonMap['data']['userDetails']['password'];
      clientId = jsonMap['data']['userDetails']['clientId'];
      clientSecret = jsonMap['data']['userDetails']['clientSecret'];
      String Ph = jsonMap['data']['userDetails']['Ph'];
      List<dynamic> buyerIds = jsonMap['data']['userDetails']['buyerIds'];
      List<dynamic> productIds = jsonMap['data']['userDetails']['productIds'];
      List<dynamic> billIds = jsonMap['data']['userDetails']['billIds'];

      UserModel user = UserModel(
        token: token,
        id: _id,
        Gstin: Gstin,
        LglNm: LglNm,
        Addr1: Addr1,
        Loc: Loc,
        Pin: Pin,
        Stcd: Stcd,
        Ph: Ph,
        accNo: accNo,
        bankName: bankName,
        branchName: branchName,
        ifscCode: ifscCode,
        userName: userName,
        password: password,
        clientId: clientId,
        clientSecret: clientSecret,
        buyerIds: buyerIds,
        productIds: productIds,
        billIds: billIds,
      );
      print(user.toMap());

      jsonMap = {
        Keys.user: [user.toMap()],
      };
      await data().createFile(Files.user, jsonMap);
      jsonMap = {
        Keys.product: [],
      };
      await data().createFile(Files.product, jsonMap);
      jsonMap = {
        Keys.customer: [],
      };
      await data().createFile(Files.customer, jsonMap);
      jsonMap = {
        Keys.bill: [],
      };
      await data().createFile(Files.bill, jsonMap);
      getCustomerDataFromDatabase();
      getProductDataFromDatabase();
      getBillDataFromDatabase();
      Navigator.of(context).pushNamed(
        HomePage.routeName,
      );
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> getCustomerDataFromDatabase() async {
    String? token = await data().retrieveAccessToken(Files.user);
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request('GET', Uri.parse(Apis.GET_BUYER));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    print("Buyer Data $res");
    if (response.statusCode == 200) {
      final data = json.decode(res);
      final List buyerResData = data['data']['rows'];
      await Provider.of<Customers>(context, listen: false)
          .databaseToFile(Files.customer, buyerResData, Keys.customer);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> getProductDataFromDatabase() async {
    String? token = await data().retrieveAccessToken(Files.user);
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request('GET', Uri.parse(Apis.GET_PRODUCT));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    print("Product Data $res");
    if (response.statusCode == 200) {
      final data = json.decode(res);
      final List buyerResData = data['data']['rows'];
      await Provider.of<Products>(context, listen: false)
          .databaseToFile(Files.product, buyerResData, Keys.product);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> getBillDataFromDatabase() async {
    String? token = await data().retrieveAccessToken(Files.user);
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request('GET', Uri.parse(Apis.GET_BILL));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    print("Bill Data $res");
    if (response.statusCode == 200) {
      final data = json.decode(res);
      final List billResData = data['data']['rows'];
      await Provider.of<Bills>(context, listen: false)
          .databaseToFile(Files.bill, billResData, Keys.bill);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> getOtp() async {
    print(Apis.GET_OTP);
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(Apis.GET_OTP));
    request.body = json.encode({
      "Ph": numberController.text,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        sendOtp = true;
      });
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle('Billing Software - Sign In');
      setWindowMinSize(const Size(800, 800));
    }
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            alignment: Alignment.center,
            height: 530,
            width: 600,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Mobile Number",
                          style: TextStyle(
                            fontSize: 15.6,
                          ),
                        ),
                      ),
                      SizedBox(
                        child: TextFormField(
                          controller: numberController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          buildCounter: (BuildContext context,
                                  {required int currentLength,
                                  required bool isFocused,
                                  int? maxLength}) =>
                              null,
                          decoration: InputDecoration(
                            suffix: InkWell(
                              onTap: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                _formKey.currentState!.save();
                                getOtp();
                              },
                              overlayColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              child: Text(
                                sendOtp ? "Resend OTP" : "Send OTP",
                                style: TextStyle(
                                  color: AppColors.black.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            isDense: true,
                            hintText: 'Enter Mobile Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Mobile Number';
                            } else {
                              if (value.length != 10) {
                                return 'Mobile Number must be 10 digits';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            // _authData['email'] = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: _formKey1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: sendOtp ? null : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5),
                              child: Text(
                                "OTP",
                                style: TextStyle(
                                  fontSize: 15.6,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: TextFormField(
                                controller: otpController,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                buildCounter: (BuildContext context,
                                        {required int currentLength,
                                        required bool isFocused,
                                        int? maxLength}) =>
                                    null,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                  isDense: true,
                                  hintText: "Enter OTP",
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
                                    return 'Please enter OTP!';
                                  } else {
                                    if (value.length != 4) {
                                      return 'OTP must be 4 digits';
                                    }
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  // _authData['email'] = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: sendOtp ? null : 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!_formKey1.currentState!.validate()) {
                                return;
                              }
                              verifyOtp();
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 18,
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text(
                              'Verify OTP',
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(SignUp.routeName);
                          },
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          child: const Text(
                            'Don\'t have an account? Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
