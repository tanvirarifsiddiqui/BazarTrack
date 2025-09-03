import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar(String? message, {bool isError = true}) {
  if(message != null && message.isNotEmpty) {
    Get.showSnackbar(GetSnackBar(
      title: isError? "Error:" : "Success",
      backgroundColor: isError ? Colors.red : Colors.green,
      message: message,
      maxWidth: Get.context?.width,
      duration: Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
      margin: EdgeInsets.all(Dimensions.paddingSizeSmall),
      borderRadius: Dimensions.radiusSmall,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    ));
  }
}