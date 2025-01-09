import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/get.dart';

String formatDateTime(DateTime dateTime) {
  final DateFormat dayFormat = DateFormat('EEEE', 'it_IT');
  final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'it_IT');

  String day = dayFormat.format(dateTime);
  String date = dateFormat.format(dateTime);

  return '$day $date';
}

IconData getMaterialIcon(String? icon) {
  return SymbolsGet.get(icon ?? "question_mark", SymbolStyle.rounded);
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else {
    return value;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
