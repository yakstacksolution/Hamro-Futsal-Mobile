import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/top_snack_bar.dart';

enum MsgType { error, success, info }

final class AppUtils {
  showSnackBar(BuildContext context, MsgType msgType, String message) {
    showTopSnackBar(
      Overlay.of(context),
      msgType == MsgType.error
          ? CustomSnackBar.error(message: message)
          : msgType == MsgType.success
              ? CustomSnackBar.success(message: message)
              : CustomSnackBar.info(message: message),
    );
  }
}
