import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'transaction_model.dart';
part 'monthly_report_model.g.dart';

@HiveType(typeId:2)
class MonthlyReportModel extends HiveObject {
  @HiveField(0)
  String monthKey;

  @HiveField(1)
  List<TransactionModel> transactions;
@HiveField(2)
double income;
@HiveField(3)
double expense;
@HiveField(4)
double remainingBudget;
  MonthlyReportModel({
    required this.monthKey,
    required this.transactions,
    required this.income,
  required this.expense,
  required this.remainingBudget,
  });
}