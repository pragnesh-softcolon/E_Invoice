class UserModel {
  final String token;

  final String id;

  final String Gstin;
  final String LglNm;

  final String Addr1;
  final String Loc;

  final int Pin;

  final String Stcd;

  final String Ph;

  final String bankName;

  final String branchName;

  final String accNo;

  final String ifscCode;

  final String userName;
  final String password;
  final String clientId;
  final String clientSecret;
  final List<dynamic> buyerIds;

  final List<dynamic> productIds;
  final List<dynamic> billIds;

  UserModel(
      {required this.token,
      required this.id,
      required this.Gstin,
      required this.LglNm,
      required this.Addr1,
      required this.Loc,
      required this.Pin,
      required this.Stcd,
      required this.Ph,
      required this.bankName,
      required this.branchName,
      required this.accNo,
      required this.ifscCode,
      required this.userName,
      required this.password,
      required this.clientId,
      required this.clientSecret,
      required this.buyerIds,
      required this.productIds,
      required this.billIds});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Gstin': Gstin,
      'LglNm': LglNm,
      'Addr1': Addr1,
      'Loc': Loc,
      'Pin': Pin,
      'Stcd': Stcd,
      'Ph': Ph,
      'bankName': bankName,
      'branchName': branchName,
      'accNo': accNo,
      'ifscCode': ifscCode,
      'userName': userName,
      'password': password,
      'clientId': clientId,
      'clientSecret': clientSecret,
      'buyerIds': buyerIds,
      'productIds': productIds,
      'billIds': billIds,
      'token': token,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'UserModel{id: $id, Gstin: $Gstin, LglNm: $LglNm, Addr1: $Addr1, Loc: $Loc, Pin: $Pin, Stcd: $Stcd, Ph: $Ph, buyerIds: $buyerIds, productIds: $productIds, billIds: $billIds,token: $token}';
  }
}
