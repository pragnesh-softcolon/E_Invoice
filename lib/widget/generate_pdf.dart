import 'package:billing_software/models/Bill/bill_model.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:billing_software/Files/data.dart' as d;

class GeneratePdf {
  Future<Uint8List> generateInvoice(
    String billId,
    Map<String, String> buyerData,
    var billList,
    String radio,
    bool isCheck,
    var irn,
    signedInvoice,
    qr,
    ackNo,
    ackDt,
    eWayBillNo,
    eWayBillDt,
    eWayValidDt,
  ) async {
    var billOne;
    print("MAC $billList");
    for (var i in billList) {
      if (i['Id'] == billId) {
        billOne = i;
        print("MAC $billOne");
        break;
      }
    }
    String date = billOne['Dt'].toString().substring(0, 10);
    Map<String, dynamic> sellerData =
        await d.data().fetchDataFromFile(Files.user, Keys.user);
    print("Buyer Data : $buyerData");
    print("Seller Data : $sellerData");
    List<Map<String, String>> tableData = [];
    List<Map<String, String>> table2Data = [];
    for (int i = 0; i < billOne['ItemList'].length; i++) {
      double taxRate =
          double.parse(billOne['ItemList'][i]['SgstAmt'].toString()) +
              double.parse(billOne['ItemList'][i]['CgstAmt'].toString());
      tableData.add({
        "No": (i + 1).toString(),
        "Product Description": billOne['ItemList'][i]['Nm'],
        "HSN Code": billOne['ItemList'][i]['HsnCd'],
        "Quantity": billOne['ItemList'][i]['Qty'].toString(),
        "Unit": billOne['ItemList'][i]['Unit'],
        "Unit Price(Rs)": billOne['ItemList'][i]['UnitPrice'].toString(),
        "Taxable Amount(Rs)": billOne['ItemList'][i]['TotAmt'].toString(),
        "Tax(%)": billOne['ItemList'][i]['GstRt'].toString(),
        "Tax Rate": taxRate.toString(),
        "Total": billOne['ItemList'][i]['TotItemVal'].toString(),
      });
    }
    for (int i = 0; i < billOne['ItemList'].length; i++) {
      table2Data.add({
        "HSN Code": billOne['ItemList'][i]['HsnCd'],
        "Taxable Amount(Rs)": billOne['ItemList'][i]['TotAmt'].toString(),
        "Rate(CGST)": billOne['ItemList'][i]['CgstRate'].toString(),
        "Amount(CGST)": billOne['ItemList'][i]['CgstAmt'].toString(),
        "Rate(SGST)": billOne['ItemList'][i]['SgstRate'].toString(),
        "Amount(SGST)": billOne['ItemList'][i]['SgstAmt'].toString(),
        "Total": billOne['ItemList'][i]['TotItemVal'].toString(),
      });
    }
    List<String> tableHeader = [
      'No',
      'Product Description',
      'HSN Code',
      'Quantity',
      'Unit',
      'Unit Price(Rs)',
      'Taxable Amount(Rs)',
      'Tax(%)',
      'Tax Rate',
      'Total',
    ];
    List<String> table2Header = [
      "HSN Code",
      "Taxable Amount(Rs)",
      "Rate(CGST)",
      "Amount(CGST)",
      "Rate(SGST)",
      "Amount(SGST)",
      "Total",
    ];
    final pdf = pw.Document();

    // Generate the QR code as an image
    final qrImageData = await QrPainter(
      data: qr,
      version: QrVersions.auto,
      gapless: true,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImageData(200);

    // Convert the QR code image data to PDF image
    final qrImage = pw.MemoryImage(Uint8List.view(qrImageData!.buffer));

    double totalTaxableAmount = 0.0;
    double totalTaxAmount = 0.0;
    double total = 0.0;
    for (var rowData in tableData) {
      double? amount1 = double.tryParse(rowData['Taxable Amount(Rs)'] ?? '0.0');
      double? amount2 = double.tryParse(rowData['Tax Rate'] ?? '0.0');
      double? amount3 = double.tryParse(rowData['Total'] ?? '0.0');
      totalTaxableAmount += amount1!;
      totalTaxAmount += amount2!;
      total += amount3!;
    }

    double totalSGST = 0.0;
    double totalCGST = 0.0;
    for (var rowData in table2Data) {
      double? sgst = double.tryParse(rowData['Amount(SGST)'] ?? '0.0');
      double? cgst = double.tryParse(rowData['Amount(CGST)'] ?? '0.0');
      totalSGST += sgst!;
      totalCGST += cgst!;
    }

// Create the total row
    final totalRow = pw.TableRow(
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      children: List.generate(tableHeader.length, (index) {
        if (index == 1) {
          return pw.Container(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Total:',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else if (index == 6) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              totalTaxableAmount.toStringAsFixed(2),
              // Display Total Tax Amount here
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else if (index == 8) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              totalTaxAmount.toStringAsFixed(2),
              // Display Total Tax Amount here
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else if (index == 9) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              total.toStringAsFixed(2), // Display Total Tax Amount here
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(''),
            padding: const pw.EdgeInsets.all(3),
          );
        }
      }),
    );

    final total2Row = pw.TableRow(
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      children: List.generate(table2Header.length, (index) {
        if (index == 0) {
          return pw.Container(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Total:',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else if (index == 1) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              totalTaxableAmount.toStringAsFixed(2),
              // Display Total Tax Amount here
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else if (index == 3) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              totalCGST.toStringAsFixed(2),
              // Display Total Tax Amount here
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else if (index == 5) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              totalSGST.toStringAsFixed(2), // Display Total Tax Amount here
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else if (index == 6) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              totalTaxAmount.toStringAsFixed(2),
              // Display Total Tax Amount here
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            padding: const pw.EdgeInsets.all(3),
          );
        } else {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(''),
            padding: const pw.EdgeInsets.all(3),
          );
        }
      }),
    );

    pw.Widget _buildHeader(pw.Context context) {
      return pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 232.5,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(),
                    top: pw.BorderSide(),
                    left: pw.BorderSide(),
                  ),
                ),
                width: 267,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      /// Company Name
                      pw.Text(
                        sellerData['LglNm'],
                        style: pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      /// Address
                      pw.Text(
                        sellerData['Addr1'],
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      /// GSTIN
                      pw.Text(
                        "GSTIN/UIN: ${sellerData['Gstin']}",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      /// State Name
                      pw.Text(
                        "Location: ${sellerData['Loc']}",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      ///State Code
                      pw.Text(
                        "State Code: ${sellerData['Stcd']}",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      /// Contact
                      pw.Text(
                        "Contact: ${sellerData['Ph']}",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Divider(),
                      pw.Text(
                        "Buyer (Bill to)",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      /// Buyers Company Name
                      pw.Text(
                        buyerData['name']!,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),

                      /// Buyer Address
                      pw.Text(
                        buyerData['address']!,
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      /// GSTIN
                      pw.Text(
                        "GSTIN/UIN: ${buyerData['gst']}",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      /// State Name
                      pw.Text(
                        "Location: ${buyerData['location']}",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),

                      ///State Code
                      pw.Text(
                        "State Code: ${buyerData['stateCode']}",
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Container(
                width: 268,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(),
                    bottom: pw.BorderSide(),
                    right: pw.BorderSide(),
                    top: pw.BorderSide(),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 134,
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    width: 65,
                                    child: pw.Text(
                                      "Invoice No.",
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                        // letterSpacing: -0.8,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.centerRight,
                                    width: 65,
                                    child: pw.Text(
                                      "e-Way Bill No.",
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                        // letterSpacing: -0.8,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    width: 60,
                                    height: 12,
                                    child: pw.Text(
                                      billOne['No'],
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        letterSpacing: -0.8,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 12,
                                    alignment: pw.Alignment.centerRight,
                                    width: 60,
                                    child: pw.Text(
                                      eWayBillNo == "0"
                                          ? ""
                                          : eWayBillNo.toString(),
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        letterSpacing: -0.8,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Bill Type",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  radio,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Reference No. & Date",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  "",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Buyer's Order No.",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  "",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Dispatch Doc. No.",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  "",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Dispatched through",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  billOne['Nm'],
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Bill of Landing/LR-RR No.",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  billOne['Lr'],
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(left: pw.BorderSide()),
                          ),
                          width: 134,
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "e-Way Bill Valid Date",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  eWayValidDt,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Mode/Terms of Payment",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  "",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Other References",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  "",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    // letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Date",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  date,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Delivery Note Date",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  "",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Destination",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  billOne['Loc'],
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                              pw.Text(
                                "Vehicle No.",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  // letterSpacing: -0.8,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                height: 12,
                                child: pw.Text(
                                  billOne['Vehno'],
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: -0.8,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                              pw.Container(
                                color: PdfColors.black,
                                height: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2),
                      height: 60,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Terms of Delivery",
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.Container(
                            height: 12,
                            child: pw.Text(
                              "TO PAY",
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(30),
        pageFormat: PdfPageFormat.a4,
        header: _buildHeader,
        build: (context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 3),
                  pw.Table(
                    border: const pw.TableBorder(
                        verticalInside: pw.BorderSide(),
                        bottom: pw.BorderSide()),
                    columnWidths: {
                      0: pw.FixedColumnWidth(20),
                      1: pw.FixedColumnWidth(110),
                      2: pw.FixedColumnWidth(50),
                      3: pw.FixedColumnWidth(50),
                      4: pw.FixedColumnWidth(30),
                      5: pw.FixedColumnWidth(50),
                      6: pw.FixedColumnWidth(60),
                      7: pw.FixedColumnWidth(30),
                      8: pw.FixedColumnWidth(50),
                      9: pw.FixedColumnWidth(70),
                      // Set the width for the eleventh column (Total)
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 1, color: PdfColors.black)),
                        children: tableHeader.map((header) {
                          return pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              header,
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Data Rows
                      ...tableData.take(10).map((rowData) {
                        return pw.TableRow(
                          children: tableHeader.mapIndexed((index, header) {
                            return pw.Container(
                              alignment: index == 1
                                  ? pw.Alignment.centerLeft
                                  : pw.Alignment.center,
                              child: pw.Text(
                                rowData[header] ?? '',
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(3),
                            );
                          }).toList(),
                        );
                      }).toList(),
                      totalRow,
                    ],
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 4, top: 4),
                    child: pw.Text("Amount Chargeable (In Words)"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                    child: pw.Text(
                      convertToIndianStyle(total.toInt()),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Table(
                    border:
                        const pw.TableBorder(verticalInside: pw.BorderSide()),
                    columnWidths: {
                      0: pw.FixedColumnWidth(40),
                      1: pw.FixedColumnWidth(30),
                      2: pw.FixedColumnWidth(20),
                      3: pw.FixedColumnWidth(25),
                      4: pw.FixedColumnWidth(20),
                      5: pw.FixedColumnWidth(25),
                      6: pw.FixedColumnWidth(30),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 1, color: PdfColors.black)),
                        children: [
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              "HSN/SAC",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              "Taxable Value",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              "Rate(CGST)",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              "Amount(CGST)",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              "Rate(SGST)",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              "Amount(SGST)",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              "Total Tax Amount",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Data Rows
                      ...table2Data.map((rowData) {
                        return pw.TableRow(
                          children: table2Header.mapIndexed((index, header) {
                            return pw.Container(
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                rowData[header] ?? '',
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(3),
                            );
                          }).toList(),
                        );
                      }).toList(),
                      total2Row,
                    ],
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 4, top: 4),
                    child: pw.Text(
                        "Tax Amount(In Words) : ${convertToIndianStyle(totalTaxAmount.toInt())}"),
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 267,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Declaration",
                              style: pw.TextStyle(
                                decoration: pw.TextDecoration.underline,
                                decorationStyle: pw.TextDecorationStyle.solid,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.",
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 268,
                        padding: const pw.EdgeInsets.only(
                          left: 4,
                          right: 2,
                          top: 4,
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Company's Bank Details",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 75,
                                  child: pw.Text(
                                    "Bank Name",
                                  ),
                                ),
                                pw.Container(
                                  width: 193,
                                  child: pw.Text(
                                    ": ${sellerData['bankName']}",
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 75,
                                  child: pw.Text(
                                    "A/c No.",
                                  ),
                                ),
                                pw.Container(
                                  width: 193,
                                  child: pw.Text(
                                    ": ${sellerData['accNo']}",
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 75,
                                  child: pw.Text(
                                    "Branch",
                                  ),
                                ),
                                pw.Container(
                                  width: 193,
                                  child: pw.Text(
                                    ": ${sellerData['branchName']}",
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 75,
                                  child: pw.Text(
                                    "IFSC Code",
                                  ),
                                ),
                                pw.Container(
                                  width: 193,
                                  child: pw.Text(
                                    ": ${sellerData['ifscCode']}",
                                  ),
                                ),
                              ],
                            ),
                            pw.Container(
                              width: 268,
                              decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                      left: pw.BorderSide(),
                                      top: pw.BorderSide())),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text("For ${sellerData['LglNm']}"),
                                  pw.SizedBox(height: 20),
                                  pw.Text("Authorised Signatory"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    height: 0.5,
                    color: PdfColors.black,
                  ),
                  if (isCheck)
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(2),
                          width: 400,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text("IRN"),
                                  ),
                                  pw.Container(
                                    width: 340,
                                    child: pw.FittedBox(
                                      child: pw.Text(": ${irn.toString()}"),
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 3),
                              pw.Row(
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text("Ack No."),
                                  ),
                                  pw.Container(
                                    width: 340,
                                    child: pw.Text(": $ackNo"),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 3),
                              pw.Row(
                                children: [
                                  pw.Container(
                                    width: 60,
                                    child: pw.Text("Ack Date"),
                                  ),
                                  pw.Container(
                                    width: 340,
                                    child: pw.Text(": $ackDt"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          width: 135,
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 2, vertical: 4),
                          child: pw.Column(
                            children: [
                              pw.Text("e-Invoice"),
                              pw.SizedBox(height: 7),
                              pw.Image(qrImage,
                                  width: 90, height: 90, fit: pw.BoxFit.cover),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )
          ];
        },
      ),
    );

    return pdf.save();
  }
}

extension IterableMapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}

String convertToIndianStyle(int number) {
  if (number == 0) {
    return 'Zero';
  }

  List<String> ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine'
  ];

  List<String> teens = [
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];

  List<String> tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];
  String words = '';
  // Crores
  int crores = number ~/ 10000000;
  if (crores > 0) {
    words += '${convertToIndianStyle(crores)} Crore ';
  }
  number %= 10000000;

  // Lakhs
  int lakhs = number ~/ 100000;
  if (lakhs > 0) {
    words += '${convertToIndianStyle(lakhs)} Lakh ';
  }
  number %= 100000;

  // Thousands
  int thousands = number ~/ 1000;
  if (thousands > 0) {
    words += '${convertToIndianStyle(thousands)} Thousand ';
  }
  number %= 1000;

  // Hundreds
  int hundred = number ~/ 100;
  if (hundred > 0) {
    words += '${ones[hundred]} Hundred ';
  }
  number %= 100;

  // Tens and Ones
  if (number >= 20) {
    words += '${tens[number ~/ 10]} ';
    number %= 10;
  }

  if (number > 0) {
    if (number < 10) {
      words += '${ones[number]} ';
    } else {
      words += '${teens[number - 10]} ';
    }
  }

  return words.trim();
}
