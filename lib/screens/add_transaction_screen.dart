import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/models/category_model.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../widgets/app_drawer.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({this.transaction, super.key});
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Misc';
  bool _isIncome = false;

  final Box<CategoryModel> categoryBox = Hive.box<CategoryModel>('categories');


  void _submitTransaction() async {
    try {
      if (_formKey.currentState!.validate()) {
        final amount = double.tryParse(_amountController.text);
        if (amount == null) return;
        final box = Hive.box<TransactionModel>('transactions');
        final allTransactions = box.values.toList();
        //  Calculate current balance
        final totalIncome = allTransactions
            .where((tx) => tx.isIncome)
            .fold(0.0, (sum, tx) => sum + tx.amount);
        final totalExpense = allTransactions
            .where((tx) => !tx.isIncome)
            .fold(0.0, (sum, tx) => sum + tx.amount);
        final currentBalance = totalIncome - totalExpense;
        // ✅ Prevent overspending
        if (!_isIncome && amount > currentBalance) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Not enough balance to add this expense.")));

          return;
        }
        // ✅ Continue adding/editing transaction
        if (widget.transaction == null) {
          final transaction = TransactionModel(
              amount: amount,
              description: _descriptionController.text,
              category: _selectedCategory,
              // date: DateTime(2025, 6, 10), //  June 10, 2025 (simulate last month)

              date: DateTime.now(),
              // DateTime.now(),
              //   date: DateTime.now().subtract(Duration(days: 32)), // force last month
              //  date: DateTime(2025, 7, 10), date is hard coded
              isIncome: _isIncome);
          await box.add(transaction);
        } else {
          widget.transaction!
            ..amount = amount
            ..description = _descriptionController.text
            ..category = _selectedCategory
            ..isIncome = _isIncome
            ..date = DateTime.now();
          //DateTime.now();
          //  DateTime(2025, 7, 10);
          //
          await widget.transaction!.save();
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Transaction saved!")));
      }
    } catch (e, stackTrace) {
      print("🚨 Error during transaction save: $e");
      print("🪵 StackTrace: $stackTrace");

      //   if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Error"),
          content: Text("Something went wrong.\n$e"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _amountController.text = tx.amount.toString();
      _descriptionController.text = tx.description;
      _selectedCategory = tx.category;
      _isIncome = tx.isIncome;

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter amount' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter description' : null,
                ),
                DropdownButtonFormField<String>(
                  value: categoryBox.values.any((category) =>
                  category.categoryName == _selectedCategory)
                      ? _selectedCategory
                      : categoryBox.values.isNotEmpty
                      ? categoryBox.values.first.categoryName
                      : null,
                  items: categoryBox.values.map((category) {
                    return DropdownMenuItem(
                        value: category.categoryName,
                        child: Text(category.categoryName));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                ),

                /* DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categoryBox.values.map((cat) {
                    return DropdownMenuItem(value: cat.categoryName, child: Text(cat.categoryName));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val!);
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                ),*/

                SwitchListTile(
                  title: Text(_isIncome ? 'Income' : 'Expense'),
                  value: _isIncome,
                  onChanged: (val) => setState(() => _isIncome = val),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _submitTransaction,
                  child: Text('Add Transaction'),
                ),
              ],
            )),
      ),
    );
  }
}