import 'package:flutter/material.dart';
import 'package:hive_financial_tracker_app/screens/transaction_list_screen.dart';
import 'package:hive_financial_tracker_app/widgets/app_drawer.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../adapter_models/category_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Box<CategoryModel> categoryBox = Hive.box<CategoryModel>('categories');
  final TextEditingController _searchController = TextEditingController();
  String _searchCategory = '';
  void _addCategoryDialog() {
    final _controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Category'),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter category name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final name = _controller.text.trim();
                  if (name.isNotEmpty) {
                    categoryBox.add(CategoryModel(categoryName: name));
                  }
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          );
        });
  }

  void _editCategoryDialog(CategoryModel categoryModel) {
    final _controller = TextEditingController(text: categoryModel.categoryName);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Category'),
            content: TextField(
              controller: _controller,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final name = _controller.text.trim();
                  if (name.isNotEmpty) {
                    categoryModel.categoryName = name;
                    categoryModel.save();
                  }
                  Navigator.pop(context);
                },
                child: Text('Update'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Screen'),
        actions: [
          IconButton(
            onPressed: () {
              _addCategoryDialog();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Search category...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchCategory.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchCategory = '';
                            });
                          },
                          icon: Icon(Icons.clear),
                        )
                      : null),
              onChanged: (val){
                setState(() {
                  _searchCategory=val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(child: ValueListenableBuilder(
              valueListenable: categoryBox.listenable(),
              builder: (context, Box<CategoryModel>box,_){
                final filtered=box.values.where((cat)=>cat.categoryName.toLowerCase().contains(_searchCategory)).toList();
                
                return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder:(context, index){
                      final cat=filtered[index];
                      return ListTile(
                        title: Text(cat.categoryName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: ()=>_editCategoryDialog(cat),  icon: Icon(Icons.edit)),
                            IconButton(onPressed: ()=>cat.delete(), icon: Icon(Icons.delete)),
                          ],
                        ),
                      );
                    } );
              })),
        ],
      ),
    );
  }
}
