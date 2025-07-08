import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/app_drawer.dart';
import '../adapter_models/category_model.dart';
import '../adapter_models/transaction_model.dart';
import '../view_model/auth_dir/finance_provider.dart';

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
  bool _isInitialized=false;
  final Box<CategoryModel> categoryBox = Hive.box<CategoryModel>('categories');

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  if(!_isInitialized){
    _isInitialized=true;

    WidgetsBinding.instance.addPostFrameCallback((_){
      final tx=widget.transaction;
      if(tx!=null){
        _amountController.text=tx.amount.toString();
        _descriptionController.text=tx.description;
        _selectedCategory=tx.category;
        _isIncome=tx.isIncome;
      /*  setState(() {

        });*/
      }
    });


  }

  }
  /*void initState() {
    super.initState();
    final provider =
    Provider.of<FinanceTrackerProvider>(context, listen: false);

    final tx = widget.transaction;
    if (tx != null) {
      _amountController.text = tx.amount.toString();
      _descriptionController.text = tx.description;
      _selectedCategory = tx.category;
      _isIncome = tx.isIncome;
    }
  }*/
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _amountController.dispose();
    _descriptionController.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
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
                    child: Text(category.categoryName),
                  );
                }).toList(),
                onChanged: (value) {
                  print("Calling setState in Add transaction Screen");
                  setState(() => _selectedCategory = value!);
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              SwitchListTile(
                title: Text(_isIncome ? 'Income' : 'Expense'),
                value: _isIncome,
                onChanged: (val) => setState(() => _isIncome = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final provider = Provider.of<FinanceTrackerProvider>(
                        context,
                        listen: false);
                    final amount = double.tryParse(_amountController.text);
                    if (amount == null) return;
                    await provider.submitTransaction(
                      context: context,
                      amount: amount,
                      description: _descriptionController.text,
                      selectedCategory: _selectedCategory,
                      isIncome: _isIncome,
                      transaction: widget.transaction,
                    );
                  }
                },
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
