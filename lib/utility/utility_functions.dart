import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';

DateTime convertTimeStampToDatetime(Timestamp timestamp) {
  if (timestamp == null) return DateTime.now();
  return DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
}

DateTime convertTimeStampToDatetimeWithNull(Timestamp timestamp) {
  if (timestamp == null) return null;
  return DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
}

String formatTimeToDatetimeString(Timestamp timestamp) {
  DateTime myDateTime = DateTime.parse(timestamp.toDate().toString());

  String formattedDay =  DateFormat('EEEE').format(myDateTime);
  String formattedTime =
  convert24HourTimeTo12Hour(myDateTime.hour, myDateTime.minute);

  String formattedDateTime =
        "${myDateTime.day.toString().padLeft(2, '0')}/${myDateTime.month.toString().padLeft(2, '0')}/${myDateTime.year.toString()} $formattedTime";

  return formattedDateTime;
}

String formatDateTimeToDayTimeString(Timestamp timestamp) {
  DateTime myDateTime = DateTime.parse(timestamp.toDate().toString());

  String formattedDay =  DateFormat('EEEE').format(myDateTime);
  String formattedTime =
  convert24HourTimeTo12Hour(myDateTime.hour, myDateTime.minute);

  // String formattedDateTime =
  //     "${myDateTime.day.toString().padLeft(2, '0')}/${myDateTime.month.toString().padLeft(2, '0')}/${myDateTime.year.toString()} $formattedTime";
  String formattedDateTime =
      "$formattedDay $formattedTime";
  return formattedDateTime;
}

String formatDateTimeDDMMYYYYString(DateTime datetime){
  var displayDate = DateFormat('MMM d, ' 'yyyy').format(datetime);
  return displayDate;
}



String convert24HourTimeTo12Hour(int hour, int minute) {
  String dayperiod;
  int hour12;
  int min12;
  if (hour > 12 && minute >= 0) {
    dayperiod = 'PM';
    hour12 = hour - 12;
    min12 = minute;
  } else if (hour < 12) {
    dayperiod = 'AM';
    hour12 = hour;
    min12 = minute;
  }
  String formattedTime =
      '${hour12.toString().padLeft(2, '0')} : ${min12.toString().padLeft(2, '0')} $dayperiod';
  return formattedTime;
}

List<String> getDaysOfWeek() {
final now = DateTime.now();
final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
return List.generate(7, (index) => index)
    .map((value) => DateFormat(DateFormat.WEEKDAY)
    .format(firstDayOfWeek.add(Duration(days: value))))
    .toList();
}