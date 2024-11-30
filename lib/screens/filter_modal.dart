// imports
import 'package:flutter/material.dart';

// filter modal class
class FilterModal extends StatefulWidget {
  // attributes needed to make a filter
  final Function(
    String category,
    String searchTerm,
    DateTime? fromDate,
    DateTime? toDate,
  )
  onApplyFilters; // this method says what needs to be done when a filter is applied

  const FilterModal({Key? key, required this.onApplyFilters}) : super(key: key);

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  // some vars, and a text editing controller to get a search param (p)
  String _selectedCategory = '';
  final TextEditingController _searchTerm = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  // categories supported by the api
  final List<String> _categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // build filter modal screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter News'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.red[200],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16), // spacing
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                hintText: 'Select Category',
              ),
              // show items from '_categories' using a dropdown menu
              items:
                  _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.toUpperCase()),
                    );
                  }).toList(),
              onChanged: (value) {
                // when user selects a category through dropdown menu,
                setState(() {
                  // _selectedCategory is changed
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16), // spacing
            // * cant use both categories and date filtering at the same time, so
            // * give the impression to user that he can only use one at a time
            const Center(child: Text('Or')),
            SizedBox(height: 16), // spacing
            // Date Range Pickers
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        // these are vars for datepicker
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          // change the state of '_fromDate' when user selects a date
                          _fromDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      // show the selected date using a 'Text'
                      _fromDate == null
                          ? 'From Date'
                          : 'From: ${_fromDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ),
                SizedBox(width: 16), // spacing
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        // these are vars for datepicker
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          // change the state of '_toDate' when user selects a date
                          _toDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      // show the selected date using a 'Text'
                      _toDate == null
                          ? 'To Date'
                          : 'To: ${_toDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // spacing
            // Search Term Input
            Center(
              child: TextField(
                controller: _searchTerm,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ),
            ),
            SizedBox(height: 16),
            // Apply Filters Button
            ElevatedButton(
              onPressed: () {
                // when pressed, the onApplyFilters method will run using selected attribs
                widget.onApplyFilters(
                  _selectedCategory,
                  _searchTerm.text,
                  _fromDate,
                  _toDate,
                );
                Navigator.pop(context); // after filtering, show news screen
              },
              child: Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
