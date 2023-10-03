class ProductData {
  final String id;
  final String name;
  final String hsnCode;
  final String unit;
  final String slNo;

  ProductData({
    required this.id,
    required this.name,
    required this.hsnCode,
    required this.unit,
    required this.slNo,
  });
  // Convert a Product into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "BchDtls": {
        "Nm":name
      },
      'HsnCd': hsnCode,
      'Unit': unit,
      'SlNo': slNo,
      'product': true,
    };
  }
  // Implement toString to make it easier to see information about
  // each product when using the print statement.
  @override
  String toString() {
    return 'ProductData{id : $id, name: $name, HsnCd: $hsnCode, Unit: $unit}';
  }
}
