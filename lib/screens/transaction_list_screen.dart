import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_financial_tracker_app/widgets/summary_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../widgets/app_drawer.dart';
import 'package:intl/intl.dart';

import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final Box<TransactionModel> _transactionBox =
      Hive.box<TransactionModel>('transactions');

  // String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  String _formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy – hh:mm:ss a').format(date);

  String _searchText = '';

  String? _selectedCategory;

  bool? _isIncome;
  // true = income, false = expense, null = all
  DateTime? _selectedDate;

  Future<void> _checkAndShowBudgetAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShownMonth = prefs.getString('budgetAlertMonth');
    final now = DateTime.now();
    final currentMonthKey = '${now.year}-${now.month}';
    if (alreadyShownMonth == currentMonthKey) return;
    final allTx = _transactionBox.values.where((tx) =>
        !tx.isIncome && tx.date.year == now.year && tx.date.month == now.month);
    final double totalExpense = allTx.fold(0.0, (sum, tx) => sum + tx.amount);
    double monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0.0;
    if (monthlyBudget == 0.0) return;
    if (totalExpense > monthlyBudget) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Budget Exceeded"),
                content: Text(
                    "You've exceeded your monthly budget of \$${monthlyBudget.toStringAsFixed(2)}!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            });
      });
      await prefs.setString('budgetAlertMonth', currentMonthKey);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAndShowBudgetAlert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Transactions')),
      drawer: AppDrawer(),
      body: ValueListenableBuilder(
        valueListenable: _transactionBox.listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          /*if (box.isEmpty) {
            return Column(
              children: [
                SummaryCard(transactionBox: _transactionBox),
                Center(child: Text("No transactions added yet.")),
              ],
            );
          }*/
          // final transactions = box.values.toList().reversed.toList();
          List<TransactionModel> transactions =
              box.values.toList().reversed.toList();

          transactions = transactions.where((tx) {
            final matchesText =
                tx.description.toLowerCase().contains(_searchText);
            final matchesCategory =
                _selectedCategory == null || tx.category == _selectedCategory;
            final matchesType = _isIncome == null || tx.isIncome == _isIncome;
            final matchesDate = _selectedDate == null ||
                (tx.date.year == _selectedDate!.year &&
                    tx.date.month == _selectedDate!.month &&
                    tx.date.day == _selectedDate!.day);
            return matchesText && matchesCategory && matchesType && matchesDate;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by description...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) =>
                          setState(() => _searchText = val.toLowerCase()),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text('Filter by Category'),
                              value: _selectedCategory,
                              items: _transactionBox.values
                                  .map((tx) => tx.category)
                                  .toSet()
                                  .map((cat) => DropdownMenuItem(
                                      value: cat, child: Text(cat)))
                                  .toList(),
                              onChanged: (value) => setState(() {
                                    _selectedCategory = value;
                                  })),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<bool>(
                            hint: Text('Type'),
                            value: _isIncome,
                            items: const [
                              DropdownMenuItem(
                                  value: true, child: Text('Income')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Expense'),
                              ),
                            ],
                            onChanged: (value) => setState(() {
                                  _isIncome = value;
                                })),
                        IconButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          icon: Icon(Icons.calendar_month),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            onPressed: () => _selectedDate = null,
                            icon: Icon(Icons.clear),
                          )
                      ],
                    ),
                  ],
                ),
              ),

              // SummaryCard(transactionBox: _transactionBox),
              Expanded(
                child: ListView.builder(
                  //  itemCount: filteredTransactions.length,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    if (tx.amount == null ||
                        tx.date == null ||
                        tx.description.isEmpty) {
                      return SizedBox.shrink();
                    }
                    return Dismissible(
                      key: Key(tx.key.toString()),
                      // direction: DismissDirection.endToStart,
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.blue,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Swipe from left to right: EDIT
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(transaction: tx),
                            ),
                          );
                          return false; // Prevent auto-dismiss
                        } else if (direction == DismissDirection.endToStart) {
                          // Swipe from right to left: DELETE
                          final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Delete Transaction"),
                                  content: Text(
                                      "Are you sure you want to delete this transaction?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                  ],
                                );

                              });
                          return confirm==true;
                        }
                        return false;
                      },
                      onDismissed: (direction) async {
                        await tx.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Transaction deleted')),
                        );
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                // builder: (context) => AddTransactionScreen(transaction: tx), // ✅ tx must not be null
                                builder: (context) {
                                  if (tx.amount == null ||
                                      tx.description == null ||
                                      tx.date == null) {
                                    return Scaffold(
                                        body: Center(
                                            child: Text(
                                                "Invalid transaction data")));
                                  }
                                  return AddTransactionScreen(transaction: tx);
                                },
                              ),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text("Delete All Transactions"),
                                      content: Text(
                                          "Are you sure you want to delete all transactions?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            //await tx.delete(); for deleting individual transaction
                                            await _transactionBox
                                                .clear(); //for deleting all transactions once
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "All transactions deleted")));
                                          },
                                          child: Text("Delete All",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Cancel")),
                                      ],
                                    ));
                          },
                          leading: CircleAvatar(
                            backgroundColor:
                                tx.isIncome ? Colors.green : Colors.red,
                            child: Icon(
                              tx.isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(tx.description),
                          subtitle:
                              Text("${tx.category} • ${_formatDate(tx.date)}"),
                          trailing: Text(
                            "${tx.isIncome ? '+' : '-'} \$${tx.amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: tx.isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
