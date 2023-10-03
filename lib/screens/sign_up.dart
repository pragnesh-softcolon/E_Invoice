import 'dart:convert';
import 'package:billing_software/models/user.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:billing_software/Files/data.dart';
import 'package:billing_software/network/apis.dart';
import 'package:billing_software/screens/home_page.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/check_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/files.dart';

class SignUp extends StatefulWidget {
  static const routeName = '/sign-up';

  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey1 = GlobalKey();

  String sign = "";

  TextEditingController legalNameController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController stateCodeController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  bool sendOtp = false;

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
        accNo: "",
        bankName: "",
        branchName: "",
        ifscCode: "",
        userName: '',
        password: '',
        clientId: '',
        clientSecret: '',
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
      Navigator.of(context).pushNamed(
        HomePage.routeName,
      );
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> signUp() async {
    _formKey1.currentState!.save();
    // setState(() {
    //   _isLoading = true;
    // });
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(Apis.SIGNUP));
    request.body = json.encode({
      "Gstin": gstController.text,
      "LglNm": legalNameController.text,
      "Addr1": addressController.text,
      "Loc": locationController.text,
      "Pin": int.parse(pinCodeController.text),
      "Stcd": stateCodeController.text,
      "Ph": numberController.text,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      sentOtp(numberController.text);
    } else {
      print(response.reasonPhrase);
    }

    setState(() {
      // _isLoading = false;
    });
  }

  Future<void> sentOtp(String number) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(Apis.GET_OTP));
    request.body = json.encode({
      "Ph": number,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(await response.stream.bytesToString());
    if (response.statusCode == 200) {
      setState(() {
        sendOtp = true;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusNode _gstFocusNode = FocusNode();
    _gstFocusNode.addListener(() {
      if (!_gstFocusNode.hasFocus && gstController.text.isNotEmpty) {
        final data = CheckState()
            .findStateByCode(int.parse(gstController.text.substring(0, 2)));
        stateCodeController.text = data["StateCode"].toString();
      }
    });
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            alignment: Alignment.center,
            width: 600,
            height: 530,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "Legal Name",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextFormField(
                                    controller: legalNameController,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      hintText: 'Enter Legal Name',
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
                                        return 'Please enter Legal Name!';
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "GSTIN",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextFormField(
                                    focusNode: _gstFocusNode,
                                    controller: gstController,
                                    textInputAction: TextInputAction.next,
                                    maxLength: 15,
                                    buildCounter: (BuildContext context,
                                            {required int currentLength,
                                            required bool isFocused,
                                            int? maxLength}) =>
                                        null,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      hintText: 'Enter GST Number',
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
                                        return 'Please enter GST Number!';
                                      } else if (value.length < 15) {
                                        return 'Please enter valid GST Number!';
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
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "Address",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextFormField(
                                    controller: addressController,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      hintText: 'Enter Address',
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
                                        return 'Please enter Address!';
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextFormField(
                                    controller: locationController,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      hintText: 'City, State',
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
                                        return 'Please enter city and state!';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "PIN Code",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextFormField(
                                    controller: pinCodeController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    buildCounter: (BuildContext context,
                                            {required int currentLength,
                                            required bool isFocused,
                                            int? maxLength}) =>
                                        null,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      hintText: 'Enter PIN Code',
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
                                        return 'Please enter PIN Code!';
                                      } else if (value.length < 6) {
                                        return 'Please enter valid PIN Code!';
                                      } else if (int.parse(value) is! int) {
                                        return 'Please enter valid PIN Code!';
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "State Code",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextFormField(
                                    controller: stateCodeController,
                                    enabled: false,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    maxLength: 2,
                                    buildCounter: (BuildContext context,
                                            {required int currentLength,
                                            required bool isFocused,
                                            int? maxLength}) =>
                                        null,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      hintText: 'Enter State Code',
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
                                        return 'Please enter State Code!';
                                      } else if (value.length < 2) {
                                        return 'Please enter valid State Code!';
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
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "Mobile Number",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextFormField(
                                    controller: numberController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    buildCounter: (BuildContext context,
                                            {required int currentLength,
                                            required bool isFocused,
                                            int? maxLength}) =>
                                        null,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter Mobile Number!';
                                      } else if (value.length < 10) {
                                        return 'Please enter valid Mobile Number!';
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
                            Column(
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  height: 35,
                                  width: 250,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }
                                          _formKey.currentState!.save();
                                          signUp();
                                        },
                                        child: Container(
                                          width: 120,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: AppColors.primary,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              sendOtp
                                                  ? "RESEND OTP"
                                                  : "SEND OTP",
                                              style: const TextStyle(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: _formKey1,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: sendOtp ? null : 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "OTP",
                                    style: TextStyle(
                                      fontSize: 15.6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      hintText: 'Enter OTP',
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
                                        return 'Please Enter OTP!';
                                      } else if (value.length < 4) {
                                        return 'Please Enter Valid OTP!';
                                      }
                                      for (var char in value.toString().runes) {
                                        if (char < 48 || char > 57) {
                                          // Check if character code is outside the range of digits (0-9)
                                          return 'Please Enter Valid Numeric OTP!';
                                        }
                                      }
                                    },
                                    onSaved: (value) {
                                      // _authData['email'] = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 30),
                              height: 35,
                              width: 250,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (!_formKey1.currentState!.validate()) {
                                        return;
                                      }
                                      verifyOtp();
                                    },
                                    child: Container(
                                      width: 120,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: AppColors.primary,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "VERIFY OTP",
                                          style: TextStyle(
                                            color: AppColors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          child: const Text(
                            'Have an account? Sign In',
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
