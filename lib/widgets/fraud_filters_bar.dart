import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class FraudFiltersBar extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final String? selectedSeverity;
  final void Function(DateTimeRange?) onDateChange;
  final void Function(String?) onSeverityChange;

  const FraudFiltersBar({
    super.key,
    required this.selectedDateRange,
    required this.selectedSeverity,
    required this.onDateChange,
    required this.onSeverityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: AppButtonStyles.secondary,
                icon: const Icon(Icons.date_range),
                label: Text(
                  selectedDateRange == null
                      ? "Filter by Date"
                      : "${DateFormat.yMMMd().format(selectedDateRange!.start)} → ${DateFormat.yMMMd().format(selectedDateRange!.end)}",
                ),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 2),
                    lastDate: now,
                    initialDateRange: selectedDateRange,
                  );
                  onDateChange(picked);
                },
              ),
            ),
            if (selectedDateRange != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onDateChange(null),
                tooltip: "Clear date filter",
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: selectedSeverity,
          onChanged: onSeverityChange,
          decoration: const InputDecoration(
            labelText: "Filter by Severity",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text("All")),
            DropdownMenuItem(value: "low", child: Text("Low")),
            DropdownMenuItem(value: "medium", child: Text("Medium")),
            DropdownMenuItem(value: "high", child: Text("High")),
          ],
        ),
      ],
    );
  }
}
