import 'package:billing_software/network/constant.dart';

class Apis {
  static String BASE_URL =
      "http://192.168.29.170:3334/api"; // Default IPv4 address

  static final SIGNUP = BASE_URL + Constant.SIGNUP;
  static final VALIDATE_OTP = BASE_URL + Constant.VALIDATE_OTP;
  static final GET_OTP = BASE_URL + Constant.GET_OTP;
  static final SYNC_BUYER = BASE_URL + Constant.SYNC_BUYER;
  static final SYNC_PRODUCT = BASE_URL + Constant.SYNC_PRODUCT;
  static final SYNC_BILL = BASE_URL + Constant.SYNC_BILL;
  static final GET_BUYER = BASE_URL + Constant.GET_BUYER;
  static final GET_PRODUCT = BASE_URL + Constant.GET_PRODUCT;
  static final GET_BILL = BASE_URL + Constant.GET_BILL;
  static final DELETE_PRODUCTS = BASE_URL + Constant.DELETE_PRODUCTS;
  static final DELETE_BUYERS = BASE_URL + Constant.DELETE_BUYERS;
  static final SYNC_USER = BASE_URL + Constant.SYNC_USER;
}
