import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TopSellingLeaderboard extends StatefulWidget {
  const TopSellingLeaderboard({super.key});

  @override
  State<TopSellingLeaderboard> createState() => _TopSellingLeaderboardState();
}

class _TopSellingLeaderboardState extends State<TopSellingLeaderboard> {
  Map<String, double> productSales = {};

  @override
  void initState() {
    super.initState();
    _fetchTopProducts();
  }

  void _fetchTopProducts() {
    FirebaseFirestore.instance.collection("transactions").snapshots().listen((snapshot) {
      final Map<String, double> salesCount = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final products = data["products"] as List<dynamic>?;

        if (products != null) {
          for (var product in products) {
            final productName = product["name"] ?? "Unknown";
            final price = product["price"] ?? 0;
            salesCount[productName] = (salesCount[productName] ?? 0) + price;
          }
        }
      }

      // Sort and take top 5
      final sorted = salesCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top5 = Map.fromEntries(sorted.take(5));

      setState(() {
        productSales = top5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return productSales.isEmpty
        ? const Center(child: Text("No sales data available yet"))
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🥇 Top-Selling Products",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: productSales.values.reduce((a, b) => a > b ? a : b) * 1.2,
              barGroups: productSales.entries.map((entry) {
                final index = productSales.keys.toList().indexOf(entry.key).toDouble();
                return BarChartGroupData(x: index.toInt(), barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Colors.blue,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ]);
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final productName = productSales.keys.elementAt(index);
                      return Text(
                        productName,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
