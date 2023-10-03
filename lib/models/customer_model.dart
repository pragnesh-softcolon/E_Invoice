class CustomerData {
  late String id;
  final String name;
  final String gstin;
  final String address;
  final String location;
  final String stateCode;
  final String pinCode;

  CustomerData({
    required this.id,
    required this.name,
    required this.gstin,
    required this.address,
    required this.location,
    required this.stateCode,
    required this.pinCode,
  });
  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Nm': name,
      'LglNm': name,
      'Gstin': gstin,
      'Addr1': address,
      'Loc': location,
      'Stcd': stateCode,
      'Pin': pinCode,
      'Pos': stateCode,
      'buyer': true,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Customer{id: $id, Nm: $name, LglNm: $name, Gstin: $gstin, Addr1: $address, Loc: $location, Stcd: $stateCode, Pin: $pinCode}';
  }
}