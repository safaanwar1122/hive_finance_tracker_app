import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/models/transaction_model.dart';
import 'package:hive_financial_tracker_app/screens/category_screen.dart';
import 'package:hive_financial_tracker_app/widgets/app_drawer.dart';
import 'package:hive_flutter/adapters.dart';

import '../widgets/summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
   late final Box<TransactionModel>transactionBox;
   
   @override
  void initState(){
    super.initState();
  
     transactionBox=Hive.box<TransactionModel>('transactions');
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: AppDrawer(),
      body: ValueListenableBuilder(
          valueListenable: transactionBox.listenable(),
          builder: (context, Box<TransactionModel>box,_){
            return Column(
              children: [
                SummaryCard(transactionBox: transactionBox),
              ],
            );
          }),
    );
  }
}
