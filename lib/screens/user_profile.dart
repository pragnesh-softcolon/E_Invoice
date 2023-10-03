import 'dart:io';

import 'package:billing_software/models/user.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:billing_software/Files/data.dart' as d;

class UserProfile extends StatefulWidget {
  static const routeName = '/User-Profile';

  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  TextEditingController gstController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController stateCodeController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController userSecretController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isHovering = false;
  bool isEdit = false;
  String userId = "";
  String token = "";
  List<dynamic> buyerIds = [];
  List<dynamic> productIds = [];
  List<dynamic> billIds = [];

  @override
  void initState() {
    getUserDetail();
    super.initState();
  }

  Future<void> getUserDetail() async {
    Map<String, dynamic> userData =
        await d.data().fetchDataFromFile(Files.user, Keys.user);
    token = userData['token'];
    buyerIds = userData['buyerIds'];
    productIds = userData['productIds'];
    billIds = userData['billIds'];
    print("sarutobi $userData");
    gstController.text = userData['Gstin'];
    nameController.text = userData['LglNm'];
    addressController.text = userData['Addr1'];
    locationController.text = userData['Loc'];
    pinController.text = userData['Pin'].toString();
    stateCodeController.text = userData['Stcd'];
    contactController.text = userData['Ph'];
    bankNameController.text = userData['bankName'];
    branchController.text = userData['branchName'];
    accountNoController.text = userData['accNo'];
    ifscController.text = userData['ifscCode'];
    userId = userData['id'];
    usernameController.text = userData['userName'];
    passController.text = userData['password'];
    userIdController.text = userData['clientId'];
    userSecretController.text = userData['clientSecret'];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle('Billing Software - Profile');
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 30,
                  child: InkWell(
                    onTap: () async {
                      if (isEdit) {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();
                        await d.data().updateUserDataById(
                              Files.user,
                              userId,
                              UserModel(
                                token: token,
                                id: userId,
                                Gstin: gstController.text,
                                LglNm: nameController.text,
                                Addr1: addressController.text,
                                Loc: locationController.text,
                                Pin: int.parse(pinController.text),
                                Stcd: stateCodeController.text,
                                Ph: contactController.text,
                                accNo: accountNoController.text,
                                bankName: bankNameController.text,
                                branchName: branchController.text,
                                ifscCode: ifscController.text.toUpperCase(),
                                userName: usernameController.text,
                                password: passController.text,
                                clientId: userIdController.text,
                                clientSecret: userSecretController.text,
                                buyerIds: buyerIds,
                                productIds: productIds,
                                billIds: billIds,
                              ).toMap(),
                            );
                      }
                      setState(() {
                        isEdit = !isEdit;
                      });
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
                      child: Text(
                        isEdit ? 'Save' : 'Edit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "GSTIN :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: false,
                        controller: gstController,
                        textInputAction: TextInputAction.next,
                        maxLength: 15,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 70),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Legal Name :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: false,
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Address :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: addressController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 70),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Location :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: locationController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter Location',
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
                            return 'Please enter Location!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "PinCode :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: pinController,
                        textInputAction: TextInputAction.next,
                        maxLength: 6,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter PinCode',
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
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 70),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "State Code :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: false,
                        controller: stateCodeController,
                        textInputAction: TextInputAction.next,
                        maxLength: 2,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 100,
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Contact :",
                    style: TextStyle(
                      fontSize: 15.6,
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.01),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 210,
                  child: TextFormField(
                    enabled: false,
                    controller: contactController,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    buildCounter: (BuildContext context,
                            {required int currentLength,
                            required bool isFocused,
                            int? maxLength}) =>
                        null,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: size.height * 0.01,
                      ),
                      isDense: true,
                      hintText: 'Enter Contact Number',
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Bank Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 30 ,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Bank Name :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: bankNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter Bank Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (bankNameController.text.isNotEmpty ||
                              branchController.text.isNotEmpty ||
                              accountNoController.text.isNotEmpty ||
                              ifscController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter Bank Name!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 70),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 30 ,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Branch :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: branchController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter Branch Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (bankNameController.text.isNotEmpty ||
                              branchController.text.isNotEmpty ||
                              accountNoController.text.isNotEmpty ||
                              ifscController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter Branch Name!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 30 ,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Account No. :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: accountNoController,
                        textInputAction: TextInputAction.next,
                        maxLength: 18,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter Account Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (bankNameController.text.isNotEmpty ||
                              branchController.text.isNotEmpty ||
                              accountNoController.text.isNotEmpty ||
                              ifscController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter Account Number!';
                            }
                            if (accountNoController.text.length < 9 ||
                                accountNoController.text.length > 18) {
                              return 'Please enter valid Account Number!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 70),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 30 ,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "IFSC :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: ifscController,
                        textInputAction: TextInputAction.next,
                        maxLength: 11,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter IFSC Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (bankNameController.text.isNotEmpty ||
                              branchController.text.isNotEmpty ||
                              accountNoController.text.isNotEmpty ||
                              ifscController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter IFSC Code!';
                            }
                            if (ifscController.text.length != 11) {
                              return 'Please enter valid IFSC Code!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Credentials",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 30 ,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Username :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (usernameController.text.isNotEmpty ||
                              passController.text.isNotEmpty ||
                              userIdController.text.isNotEmpty ||
                              userSecretController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter username!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 70),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 30 ,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Password :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: passController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
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
                          if (usernameController.text.isNotEmpty ||
                              passController.text.isNotEmpty ||
                              userIdController.text.isNotEmpty ||
                              userSecretController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter password!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 30 ,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "UserId :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: userIdController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter UserId',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (usernameController.text.isNotEmpty ||
                              passController.text.isNotEmpty ||
                              userIdController.text.isNotEmpty ||
                              userSecretController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter userId!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 70),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 30 ,
                      width: 100,
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "User Secret :",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 210,
                      child: TextFormField(
                        enabled: isEdit,
                        controller: userSecretController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          isDense: true,
                          hintText: 'Enter User Secret',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (usernameController.text.isNotEmpty ||
                              passController.text.isNotEmpty ||
                              userIdController.text.isNotEmpty ||
                              userSecretController.text.isNotEmpty) {
                            if (value!.isEmpty) {
                              return 'Please enter user secret!';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
