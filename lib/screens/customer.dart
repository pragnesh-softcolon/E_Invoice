import 'package:billing_software/models/customer_model.dart';
import 'package:billing_software/providers/customers.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

import '../utils/check_state.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

bool _isHovering = false;
bool edit = false;

class _CustomerState extends State<Customer> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _gstinController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _stateCodeController = TextEditingController();
  TextEditingController _pinController = TextEditingController();

  String id = "";

  @override
  void dispose() {
    _nameController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _stateCodeController.dispose();
    super.dispose();
  }

  Future<void> saveCustomer() async {
    if (edit) {
      await Provider.of<Customers>(context, listen: false).updateUserDataById(
        Files.customer,
        id,
        CustomerData(
          id: id,
          name: _nameController.text,
          gstin: _gstinController.text,
          address: _addressController.text,
          location: _locationController.text,
          stateCode: _stateCodeController.text,
          pinCode: _pinController.text,
          // slNo: slNo,
        ).toMap(),
        Keys.customer,
      );
      setState(() {
        edit = false;
      });
    } else {
      DateTime now = DateTime.now();
      String id = DateFormat('ddMMyyHHmmss').format(now);
      // if(slNo.isEmpty) {
      //   slNo = "0";
      // }
      // String slNum = (int.parse(slNo) + 1).toString();
      await Provider.of<Customers>(context, listen: false).addNewDataToFile(
        Files.customer,
        CustomerData(
          id: id,
          name: _nameController.text,
          gstin: _gstinController.text,
          address: _addressController.text,
          location: _locationController.text,
          stateCode: _stateCodeController.text,
          pinCode: _pinController.text,
          // slNo: slNum,
        ).toMap(),
        Keys.customer,
      );
    }
    _nameController.clear();
    _gstinController.clear();
    _addressController.clear();
    _locationController.clear();
    _stateCodeController.clear();
    _pinController.clear();
    id = "";
  }

  void editCustomer(CustomerData customer) {
    _nameController.text = customer.name;
    _gstinController.text = customer.gstin;
    _addressController.text = customer.address;
    _locationController.text = customer.location;
    _stateCodeController.text = customer.stateCode;
    _pinController.text = customer.pinCode;
    id = customer.id;
    // slNo = customer.slNo;
  }

  List<DataRow> buildTableRows(List customers) {
    return customers.asMap().entries.map((entry) {
      int index = entry.key;
      CustomerData customer = entry.value;

      return DataRow(
        cells: [
          DataCell(Text(customer.name)),
          DataCell(Text(customer.gstin)),
          DataCell(Text(customer.address)),
          DataCell(Text(customer.location)),
          DataCell(Text(customer.stateCode)),
          DataCell(Text(customer.pinCode)),
          DataCell(IconButton(
            onPressed: () {
              setState(() {
                edit = true;
              });
              editCustomer(customer); // Call the edit function here
            },
            icon: const Icon(Icons.edit),
          )),
          DataCell(IconButton(
            onPressed: () async {
              /// Alert Dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Customer"),
                    content: const Text("Are you sure you want to delete?"),
                    actions: [
                      TextButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await Provider.of<Customers>(context, listen: false)
                              .deleteUserDataById(
                                  Files.customer, customer.id, Keys.customer);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete),
          )),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final customers = Provider.of<Customers>(context).customers;
    FocusNode _gstFocusNode = FocusNode();
    _gstFocusNode.addListener(() {
      print("Has focus: ${_gstFocusNode.hasFocus}");
      if (!_gstFocusNode.hasFocus && _gstinController.text.isNotEmpty) {
        final data = CheckState()
            .findStateByCode(int.parse(_gstinController.text.substring(0, 2)));
        setState(() {
          _stateCodeController.text = data["StateCode"].toString();
        });
      }
    });
    Size size = MediaQuery.of(context).size;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle('Billing Software - Customer');
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.01),
                      child: const Text(
                        "Customer Name",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          hintText: 'Enter Customer Name',
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
                            return 'Please enter Customer Name!';
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
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.01),
                      child: const Text(
                        "GSTIN",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: _gstinController,
                        focusNode: _gstFocusNode,
                        maxLength: 15,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        textInputAction: TextInputAction.next,
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
                          } else if (Provider.of<Customers>(context,
                                  listen: false)
                              .isGstExist(value) && !edit) {
                            return 'GST Number already exist!';
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
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.01),
                      child: const Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: _addressController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
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
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.01),
                      child: const Text(
                        "Location",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: _locationController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
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
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.01),
                      child: const Text(
                        "State Code",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: _stateCodeController,
                        enabled: false,
                        maxLength: 2,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
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
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.01),
                      child: const Text(
                        "PinCode",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: _pinController,
                        maxLength: 6,
                        buildCounter: (BuildContext context,
                                {required int currentLength,
                                required bool isFocused,
                                int? maxLength}) =>
                            null,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
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
                            return 'Please enter Pin Code!';
                          } else if (value.length < 6) {
                            return 'Please enter valid Pin Code!';
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
                Container(
                  margin: EdgeInsets.only(top: size.width > 1600 ? 40 : 20),
                  width: 320,
                  child: InkWell(
                    onTap: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      _formKey.currentState!.save();
                      saveCustomer();
                    },
                    hoverColor: Colors.blue.shade50,
                    onHover: (value) {
                      setState(() {
                        _isHovering = value;
                      });
                    },
                    child: Container(
                      height: 34,
                      width: 320,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: const Text(
                        'Save',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: size.height * 0.02,
          ),

          // Wrap the table with Expanded and SingleChildScrollView
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Customer Name")),
                  DataColumn(label: Text("GSTIN")),
                  DataColumn(label: Text("Address")),
                  DataColumn(label: Text("Location")),
                  DataColumn(label: Text("State Code")),
                  DataColumn(label: Text("PinCode")),
                  DataColumn(label: Text("Edit")),
                  DataColumn(label: Text("Delete")),
                ],
                rows: buildTableRows(customers),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
