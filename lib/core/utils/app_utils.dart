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

  Map<String, dynamic> cleanUnwantedMapValue(Map<String, dynamic> input) {
    Map<String, dynamic> cleanedMap = {};

    input.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        Map<String, dynamic> nestedMap = cleanUnwantedMapValue(value);
        if (nestedMap.isNotEmpty) {
          cleanedMap[key] = nestedMap;
        }
      } else if (value is List) {
        List<dynamic> cleanedList = value.where((item) {
          if (item is Map<String, dynamic>) {
            return cleanUnwantedMapValue(item).isNotEmpty;
          }
          return item != null && item.toString().isNotEmpty;
        }).toList();

        if (cleanedList.isNotEmpty) {
          cleanedMap[key] = cleanedList;
        }
      } else if (value != null && value.toString().isNotEmpty) {
        cleanedMap[key] = value;
      }
    });

    return cleanedMap;
  }
}
