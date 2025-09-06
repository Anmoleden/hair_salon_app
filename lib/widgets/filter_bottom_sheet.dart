import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../classifiers/filters_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final Filters currentFilters;
  final Function(Filters) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Filters filters;

  @override
  void initState() {
    super.initState();
    filters = Filters(
      gender: widget.currentFilters.gender,
      length: widget.currentFilters.length,
    );
  }

  Widget buildDropdown({
    required String label,
    required List<String> items,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade100,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              icon: const Icon(Icons.arrow_drop_down),
              style: GoogleFonts.poppins(color: Colors.black),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Filter Hairstyles",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          buildDropdown(
            label: "Gender",
            items: ["All", "Male", "Female"],
            value: filters.gender,
            onChanged: (val) => setState(() => filters.gender = val!),
          ),
          const SizedBox(height: 16),
          buildDropdown(
            label: "Length",
            items: ["All", "Short", "Medium", "Long"],
            value: filters.length,
            onChanged: (val) => setState(() => filters.length = val!),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(filters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.black,
              ),
              child: Text(
                "Apply Filters",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
