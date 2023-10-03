import 'package:billing_software/models/product_model.dart';
import 'package:billing_software/providers/products.dart';
import 'package:billing_software/utils/app_color.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

class Product extends StatefulWidget {
  static const routeName = '/product-page';

  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

bool _isHovering = false;
bool edit = false;

class _ProductState extends State<Product> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController hsnCodeController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  String id = "";

  String slNo = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    productNameController.dispose();
    hsnCodeController.dispose();
    unitController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    if (edit) {
      await Provider.of<Products>(context, listen: false).updateProdDataById(
        Files.product,
        id,
        ProductData(
          id: id,
          name: productNameController.text,
          hsnCode: hsnCodeController.text,
          unit: unitController.text,
          slNo: slNo,
        ).toMap(),
        Keys.product,
      );
      setState(() {
        edit = false;
      });
    } else {
      slNo = Provider.of<Products>(context, listen: false).getSlNo();
      String slNum = (int.parse(slNo) + 1).toString();
      DateTime now = DateTime.now();
      String id = DateFormat('ddMMyyHHmmss').format(now);
      await Provider.of<Products>(context, listen: false).addNewDataToFile(
        Files.product,
        ProductData(
          id: id,
          name: productNameController.text,
          hsnCode: hsnCodeController.text,
          unit: unitController.text,
          slNo: slNum,
        ).toMap(),
        Keys.product,
      );
    }
    productNameController.clear();
    hsnCodeController.clear();
    unitController.clear();
    id = "";
  }

  void editProduct(ProductData product) {
    productNameController.text = product.name;
    hsnCodeController.text = product.hsnCode;
    unitController.text = product.unit;
    id = product.id;
    slNo = product.slNo;
  }

  List<DataRow> buildTableRows(List products) {
    return products.asMap().entries.map(
      (entry) {
        int index = entry.key;
        ProductData product = entry.value;

        return DataRow(
          cells: [
            DataCell(Text(product.name)),
            DataCell(Text(product.hsnCode)),
            DataCell(Text(product.unit)),
            DataCell(IconButton(
              onPressed: () {
                setState(() {
                  edit = true;
                });
                editProduct(product);
              },
              icon: const Icon(Icons.edit),
            )),
            DataCell(
              IconButton(
                onPressed: () {
                  /// Alert Dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Product"),
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
                              Navigator.of(context).pop();
                              Provider.of<Products>(context, listen: false)
                                  .deleteProdDataById(
                                      Files.product, product.id, Keys.product);
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          ],
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context).products;
    Size size = MediaQuery.of(context).size;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle('Billing Software - Products');
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
                        "Product Name",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: productNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: size.height * 0.01,
                          ),
                          hintText: 'Enter Product Name',
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
                            return 'Please enter Product Name!';
                          }
                          return null;
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
                        "HSN Code",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: hsnCodeController,
                        textInputAction: TextInputAction.next,
                        maxLength: 8,
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
                          hintText: 'Enter HSN Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter HSN Code!';
                          } else if (value.length < 4) {
                            return 'Please enter valid HSN Code!';
                          }
                          return null;
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
                        "Unit",
                        style: TextStyle(
                          fontSize: 15.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: unitController,
                        maxLength: 8,
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
                          hintText: 'Enter Unit',
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
                            return 'Please enter unit!';
                          } else if (value.length < 3) {
                            return 'Please enter valid unit!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (size.width > 1700)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.01),
                        child: const Text(
                          "",
                          style: TextStyle(
                            fontSize: 15.6,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    Container(
                      margin: size.width < 1700
                          ? const EdgeInsets.only(top: 20)
                          : null,
                      width: 320,
                      child: InkWell(
                        onTap: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          _formKey.currentState!.save();
                          saveProduct(); // Call the saveCustomer function here
                        },
                        hoverColor: Colors.blue.shade50,
                        onHover: (value) {
                          setState(() {
                            _isHovering = value;
                          });
                        },
                        child: Container(
                          width: 70,
                          height: 35,
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
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Product Name")),
                  DataColumn(label: Text("HSN Code")),
                  DataColumn(label: Text("Unit")), // Add the "Unit" column here
                  DataColumn(label: Text("Edit")),
                  DataColumn(label: Text("Delete")),
                ],
                rows: buildTableRows(products),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
