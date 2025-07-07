import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'transaction_model.g.dart';
@HiveType(typeId: 0)
class TransactionModel extends HiveObject{
  @HiveField(0)
   double amount;
  @HiveField(1)
   String description;
  @HiveField(2)
  String category;
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  bool isIncome;
  TransactionModel({
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.isIncome
});
}