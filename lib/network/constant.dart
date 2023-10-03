class Constant {
  static const SIGNUP = "/user/signup";
  static const VALIDATE_OTP = "/user/validate_otp";
  static const GET_OTP = "/user/get_otp";
  static const ADD_BUYER = "/buyer/add_buyer";
  static const GET_BUYER = "/buyer/get_buyer";
  static const SYNC_BUYER = "/offline_data/add_buyers";
  static const SYNC_PRODUCT = "/offline_data/add_products";
  static const SYNC_BILL = "/offline_data/add_bills";
  static const GET_PRODUCT = "/user/get_product";
  static const GET_BILL = "/user/get_bills";
  static const DELETE_PRODUCTS = "/offline_data/delete_products";
  static const DELETE_BUYERS = "/offline_data/delete_buyers";
  static const SYNC_USER = "/offline_data/user_details";

  /// E-Invoice
  static const AUTH = "/einvoice/authenticate?email=pragnesh.softcolon@gmail.com";
  static const GENERATE_IRN = "/einvoice/type/GENERATE/version/V1_03?email=pragnesh.softcolon@gmail.com";
  static const CANCEL_IRN = "/einvoice/type/CANCEL/version/V1_03?email=pragnesh.softcolon@gmail.com";
  static const GENERATE_EWAYBILL = "/einvoice/type/GENERATE_EWAYBILL/version/V1_03?email=pragnesh.softcolon@gmail.com";
}
