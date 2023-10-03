import 'package:billing_software/network/constant.dart';

class GenerateEInvoice {
  static String BASE_URL = "https://api.mastergst.com";

  static final AUTH = BASE_URL + Constant.AUTH;
  static final GENERATE_IRN = BASE_URL + Constant.GENERATE_IRN;
  static final CANCEL_IRN = BASE_URL + Constant.CANCEL_IRN;
  static final GENERATE_EWAYBILL = BASE_URL + Constant.GENERATE_EWAYBILL;
}
