import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/widgets/app_drawer.dart';
import 'package:pie_chart/pie_chart.dart' as pie; // 👈 give prefix for pie_chart
import 'package:fl_chart/fl_chart.dart';

import '../adapter_models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Box<TransactionModel> transactionBox;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
  }

  @override
  Widget build(BuildContext context) {
    final transactions = transactionBox.values.toList();
    double totalIncome = 0;
    double totalExpense = 0;

    Map<DateTime, double> incomePerDay = {};
    Map<DateTime, double> expensePerDay = {};

    for (var tx in transactions) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);

      if (tx.isIncome) {
        totalIncome += tx.amount;
        incomePerDay[day] = (incomePerDay[day] ?? 0) + tx.amount;
      } else {
        totalExpense += tx.amount;
        expensePerDay[day] = (expensePerDay[day] ?? 0) + tx.amount;
      }
    }

    Map<String, double> dataMap = {
      "Income": totalIncome,
      "Expense": totalExpense,
    };

    /*List<DateTime> sortedDays = [
      ...incomePerDay.keys,
      ...expensePerDay.keys,
    ].toSet().toList()
      ..sort();
*/
    // Combine all unique days
    List<DateTime> sortedDays = [];
    if(transactions.isNotEmpty){
      final allDates=transactions.map((t)=>DateTime(t.date.year, t.date.month, t.date.day)).toList();
      allDates.sort();
      DateTime startDate=allDates.first;
      DateTime endDate=allDates.last;
      for (DateTime day = startDate;
      !day.isAfter(endDate);
      day = day.add(Duration(days: 1))) {
        sortedDays.add(day);
      }

    }

    // Use index-based x-axis (0, 1, 2, ...)
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];

    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      incomeSpots.add(FlSpot(i.toDouble(), incomePerDay[day] ?? 0));
      expenseSpots.add(FlSpot(i.toDouble(), expensePerDay[day] ?? 0));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Screen'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Income vs Expense Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            pie.PieChart(
              dataMap: dataMap,
              chartRadius: MediaQuery.of(context).size.width / 2,
              colorList: [Colors.green, Colors.red],
              chartType: pie.ChartType.ring,
              ringStrokeWidth: 28,
              legendOptions: pie.LegendOptions(
                legendPosition: pie.LegendPosition.bottom,
                showLegends: true,
              ),
              chartValuesOptions: pie.ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValuesOutside: true,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Daily Income vs Expense (Line Chart)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (sortedDays.length - 1).toDouble(),
                  minY: 0,
                  maxY: ([
                    ...incomePerDay.values,
                    ...expensePerDay.values,
                  ].isNotEmpty
                      ? [
                    ...incomePerDay.values,
                    ...expensePerDay.values,
                  ].reduce((a, b) => a > b ? a : b)
                      : 100) + 50,


                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < sortedDays.length) {
                            final date = sortedDays[index];
                            return Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return Text('');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}'),
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),

                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),

                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




/*
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Box<TransactionModel>transactionBox;

  @override
  void initState(){
    super.initState();
  transactionBox=Hive.box<TransactionModel>('transactions');

  }
  @override

  Widget build(BuildContext context) {
    final transactions=transactionBox.values.toList();
    double totalIncome=0;
    double totalExpense=0;
    Map<DateTime, double> incomePerDay={};
    Map<DateTime, double> expensePerDay={};

    for(var tx in transactions){
      final day=DateTime(tx.date.year, tx.date.month, tx.date.day);

      if(tx.isIncome){
        totalIncome+=tx.amount;
        incomePerDay[day]=(incomePerDay[day]??0)+tx.amount;
      }
      else{
        totalExpense+=tx.amount;
        expensePerDay[day]=(expensePerDay[day]??0)+tx.amount;
      }
    }
    Map<String, double>dataMap={
      "Income":totalIncome,
      "Expense":totalExpense,
    };
    List<DateTime>sortedDays=[
      ...incomePerDay.keys,
      ...expensePerDay.keys,
    ].toSet().toList()..sort();

    List<FlSpot>incomeSpots=sortedDays.map((day){
      return FlSpot(day.difference(sortedDays.first).inDays.toDouble(),
          incomePerDay[day]??0,);
    }).toList();

    List<FlSpot> expenseSpots=sortedDays.map((day){
      return FlSpot(day.difference(sortedDays.first).inDays.toDouble(),
          expensePerDay[day]??0);
    }).toList();


    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Screen'),
      ),
      drawer: AppDrawer(),
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Income vs Expense Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          pie.PieChart(dataMap: dataMap,
          chartRadius: MediaQuery.of(context).size.width/2,
            colorList: [
              Colors.grey,
              Colors.red,
            ],
            chartType: pie.ChartType.ring,
            ringStrokeWidth: 28,
            legendOptions: pie.LegendOptions(
              legendPosition: pie.LegendPosition.bottom,
              showLegends: true,
            ),
            chartValuesOptions: pie.ChartValuesOptions(
              showChartValuesInPercentage: true,
              showChartValuesOutside: true,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Daily Income vs Expense (Line Chart)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 250,
            child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: sortedDays.length.toDouble() - 1,
                  minY: 0,
                  maxY: ([
                    ...incomePerDay.values,
                    ...expensePerDay.values
                  ].reduce((a, b) => a > b ? a : b)) + 50, // Add some buffer

                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < sortedDays.length) {
                            final date = sortedDays[index];
                            return Text('${date.day}/${date.month}',
                                style: TextStyle(fontSize: 10));
                          }
                          return Text('');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),

                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),

                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    )
                  ],
                ),

            ),
          ),
        ],
      ),
      ),
    );
  }
}
*/
