class ItemList {
  final String isServc;
  final String slNo;
  final String item;
  final String hsnCode;
  final String unit;
  final int qty;
  final int totAmt;
  final int unitPrice;
  final int cgstRate;
  final int sgstRate;
  final double cgstAmt;
  final double sgstAmt;
  final int assAmt;
  final int gstRt;
  final double totItemVal;

  ItemList({
    required this.isServc,
    required this.slNo,
    required this.item,
    required this.hsnCode,
    required this.unit,
    required this.qty,
    required this.totAmt,
    required this.unitPrice,
    required this.cgstRate,
    required this.sgstRate,
    required this.cgstAmt,
    required this.sgstAmt,
    required this.assAmt,
    required this.gstRt,
    required this.totItemVal,
  });

  Map<String, dynamic> toJson() {
    return {
      'IsServc': isServc,
      'SlNo': slNo,
      'Nm': item,
      'HsnCd': hsnCode,
      'Unit': unit,
      'Qty': qty,
      'TotAmt': totAmt,
      'UnitPrice': unitPrice,
      'CgstRate': cgstRate,
      'SgstRate': sgstRate,
      'CgstAmt': cgstAmt,
      'SgstAmt': sgstAmt,
      'AssAmt': assAmt,
      'GstRt': gstRt,
      'TotItemVal': totItemVal,
    };
  }

  @override
  String toString() {
    return '{isServc: $isServc, Nm: $item, HsnCd: $hsnCode, unit: $unit, qty: $qty, totAmt: $totAmt, unitPrice: $unitPrice, cgstRate: $cgstRate, sgstRate: $sgstRate, cgstAmt: $cgstAmt, sgstAmt: $sgstAmt, assAmt: $assAmt, gstRt: $gstRt, totItemVal: $totItemVal}';
  }
}
