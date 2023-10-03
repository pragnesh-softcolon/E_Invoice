import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessage {
  void showToast(String msg, BuildContext context, bool positive) {
    Size size = MediaQuery.of(context).size;
    FToast().init(context);
    FToast().showToast(
      toastDuration: const Duration(seconds: 4),
      child: Container(
        height: 40,
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: positive ? Colors.green : Colors.red,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: FittedBox(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
