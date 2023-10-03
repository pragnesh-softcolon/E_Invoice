import 'iteam.dart';

class BillData {
  String id;
  String no;
  String buyerId;
  String othRefNo;
  List<ItemList> itemList;
  int assVal;
  double totInvVal;
  int distance;
  String vehno;
  String nm;
  String loc;
  String lr;
  String irn;
  String eWayBillNo;
  String eWayBillDt;
  String eWayBillValidDt;
  String qr;
  String ackNo;
  String ackDt;
  String signedInv;
  bool isEInv;
  DateTime dt;

  BillData({
    required this.id,
    required this.no,
    required this.buyerId,
    required this.othRefNo,
    required this.itemList,
    required this.assVal,
    required this.totInvVal,
    required this.distance,
    required this.vehno,
    required this.nm,
    required this.loc,
    required this.lr,
    required this.irn,
    required this.signedInv,
    required this.qr,
    required this.ackDt,
    required this.ackNo,
    required this.eWayBillNo,
    required this.eWayBillDt,
    required this.eWayBillValidDt,
    required this.isEInv,
    required this.dt,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'No': no,
      'BuyerId': buyerId,
      'OthRefNo': othRefNo,
      'ItemList': itemList.map((item) => item.toJson()).toList(),
      'AssVal': assVal,
      'TotInvVal': totInvVal,
      'Distance': distance,
      'Vehno': vehno,
      'Nm': nm,
      'Loc': loc,
      'Lr': lr,
      'IRN': irn,
      'qr': qr,
      'ackNo': ackNo,
      'ackDt': ackDt,
      'signedInv': signedInv,
      'eWayBillNo': eWayBillNo,
      'eWayBillDt': eWayBillDt,
      'eWayBillValidDt': eWayBillValidDt,
      'isEInv': isEInv,
      'Dt': dt.toIso8601String(),
      'bill': true,
    };
  }

  @override
  String toString() {
    return 'Bill{no: $no, buyerId: $buyerId, othRefNo: $othRefNo, itemList: $itemList, assVal: $assVal, totInvVal: $totInvVal, distance: $distance, vehno: $vehno, nm: $nm, loc: $loc, dt: $dt}';
  }
}
