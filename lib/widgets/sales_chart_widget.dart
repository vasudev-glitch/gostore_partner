import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesChartWidget extends StatefulWidget {
  const SalesChartWidget({super.key});

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  List<FlSpot> spots = [];
  List<String> xLabels = [];

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  void _loadSalesData() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 6)); // Last 7 days

    FirebaseFirestore.instance
        .collection('transactions')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .snapshots()
        .listen((snapshot) {
      final dailyRevenue = <String, double>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data["timestamp"];
        final amount = data["totalAmount"];

        if (timestamp is Timestamp && amount is num) {
          final date = timestamp.toDate();
          final dateStr = DateFormat('dd-MM').format(date);
          dailyRevenue[dateStr] = (dailyRevenue[dateStr] ?? 0) + amount.toDouble();
        }
      }

      final sortedKeys = dailyRevenue.keys.toList()..sort();
      final labels = <String>[];
      final chartSpots = <FlSpot>[];

      for (int i = 0; i < sortedKeys.length; i++) {
        final key = sortedKeys[i];
        labels.add(key);
        chartSpots.add(FlSpot(i.toDouble(), dailyRevenue[key]!));
      }

      setState(() {
        spots = chartSpots;
        xLabels = labels;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return spots.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < xLabels.length) {
                    return Text(
                      xLabels[index],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withAlpha(50), // Replaces withOpacity
              ),
            ),
          ],
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}
