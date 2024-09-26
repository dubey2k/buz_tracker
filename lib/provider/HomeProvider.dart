import 'package:buz_tracker/model/DailyExpenseModel.dart';
import 'package:buz_tracker/model/MonthlyExpenseModel.dart';
import 'package:buz_tracker/model/YearlyExpenseModel.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  final Map<String, DailyExpenseModel> dailyMap = {};
  final Map<String, List<MonthlyExpenseModel>> monthlyMap = {};
  final Map<String, List<YearlyExpenseModel>> yearlyMap = {};

  addIntoDailyMap(DateTime date, DailyExpenseModel data) {
    date = DateUtils.dateOnly(date);
    dailyMap.putIfAbsent(date.toString(), () => data);
  }

  bool dailyKeyExists(DateTime date) {
    date = DateUtils.dateOnly(date);
    return dailyMap.containsKey(date.toString());
  }

  DailyExpenseModel? getFromDailyMap(DateTime date) {
    date = DateUtils.dateOnly(date);
    return dailyMap[date.toString()];
  }

  addIntoMonthlyMap(DateTime date, List<MonthlyExpenseModel> data) {
    date = DateUtils.dateOnly(date);
    monthlyMap.putIfAbsent(date.toString(), () => data);
  }

  bool monthlyKeyExists(DateTime date) {
    date = DateUtils.dateOnly(date);
    return monthlyMap.containsKey(date.toString());
  }

  List<MonthlyExpenseModel>? getFromMonthlyMap(DateTime date) {
    date = DateUtils.dateOnly(date);
    return monthlyMap[date.toString()];
  }

  addIntoYearlyMap(DateTime date, List<YearlyExpenseModel> data) {
    date = DateUtils.dateOnly(date);
    yearlyMap.putIfAbsent(date.toString(), () => data);
  }

  bool yearlyKeyExists(DateTime date) {
    date = DateUtils.dateOnly(date);
    return yearlyMap.containsKey(date.toString());
  }

  List<YearlyExpenseModel>? getFromYearlyMap(DateTime date) {
    date = DateUtils.dateOnly(date);
    return yearlyMap[date.toString()];
  }
}
