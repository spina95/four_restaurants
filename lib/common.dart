import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  final DateFormat dayFormat = DateFormat('EEEE', 'it_IT');
  final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'it_IT');

  String day = dayFormat.format(dateTime);
  String date = dateFormat.format(dateTime);

  return '$day $date';
}
