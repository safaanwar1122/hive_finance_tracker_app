import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


part 'category_model.g.dart';
@HiveType(typeId: 1)
class CategoryModel extends HiveObject{
  @HiveField(0)
  String categoryName;
  CategoryModel({
    required this.categoryName
});
}