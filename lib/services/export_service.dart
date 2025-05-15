import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> exportSalesReport({required bool asPdf}) async {
    final snapshot = await _firestore.collection("transactions").orderBy("timestamp", descending: true).get();
    final now = DateTime.now();
    final fileName = "sales_report_${DateFormat('yyyyMM').format(now)}";

    final data = snapshot.docs.map((doc) {
      final d = doc.data();
      return [
        d["userId"],
        d["totalAmount"].toString(),
        d["method"] ?? "Unknown",
        d["timestamp"] != null
            ? DateFormat('dd-MM-yyyy').format((d["timestamp"] as Timestamp).toDate())
            : ""
      ];
    }).toList();

    final headers = ["User ID", "Amount", "Method", "Date"];

    if (asPdf) {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Table.fromTextArray(headers: headers, data: data),
        ),
      );
      final file = await _savePdf(pdf, "$fileName.pdf");
      await Printing.layoutPdf(onLayout: (_) => file.readAsBytes());
    } else {
      final csv = const ListToCsvConverter().convert([headers, ...data]);
      final file = await _saveCsv(csv, "$fileName.csv");
      await Printing.sharePdf(bytes: await file.readAsBytes(), filename: "$fileName.csv");
    }
  }

  Future<void> exportInventoryReport({required bool asPdf}) async {
    final snapshot = await _firestore.collection("inventory").get();
    final now = DateTime.now();
    final fileName = "inventory_report_${DateFormat('yyyyMM').format(now)}";

    final data = snapshot.docs.map((doc) {
      final d = doc.data();
      return [
        d["name"],
        d["category"] ?? "Uncategorized",
        d["stock"].toString(),
        d["price"].toString(),
      ];
    }).toList();

    final headers = ["Product Name", "Category", "Stock", "Price"];

    if (asPdf) {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Table.fromTextArray(headers: headers, data: data),
        ),
      );
      final file = await _savePdf(pdf, "$fileName.pdf");
      await Printing.layoutPdf(onLayout: (_) => file.readAsBytes());
    } else {
      final csv = const ListToCsvConverter().convert([headers, ...data]);
      final file = await _saveCsv(csv, "$fileName.csv");
      await Printing.sharePdf(bytes: await file.readAsBytes(), filename: "$fileName.csv");
    }
  }

  Future<void> exportFraudLogsCsv() async {
    final snapshot = await _firestore.collection("fraud_logs").get();
    final now = DateTime.now();
    final fileName = "fraud_logs_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv";

    final data = snapshot.docs.map((doc) {
      final d = doc.data();
      return [
        doc.id,
        d["description"] ?? "No description",
        (d["timestamp"] as Timestamp?)?.toDate().toIso8601String() ?? "",
        d["resolved"] == true ? "Resolved" : "Unresolved",
      ];
    }).toList();

    final headers = ["Fraud ID", "Description", "Timestamp", "Status"];
    final csv = const ListToCsvConverter().convert([headers, ...data]);
    final file = await _saveCsv(csv, fileName);

    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: fileName,
    );
  }

  Future<File> _saveCsv(String data, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$filename");
    await file.writeAsString(data);
    return file;
  }

  Future<File> _savePdf(pw.Document pdf, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$filename");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}