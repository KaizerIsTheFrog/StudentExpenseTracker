import 'package:flutter/material.dart';

import 'expense_database.dart';

/// Collects, validates, confirms, and saves a single expense record.
class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'Food';
  String? _selectedDate;
  bool _isSaving = false;

  static const List<String> _categories = [
    'Food',
    'Transport',
    'Books',
    'Housing',
    'Entertainment',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _confirmExpenseEntry() async {
    // Do not ask for confirmation until required fields pass validation.
    if (!_formKey.currentState!.validate()) return;

    // The date is required; the date picker is the only way to set it.
    if (_selectedDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm expense entry'),
        content: const Text('Save this expense record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Return the save result to the home screen so it can reload page 1.
    setState(() => _isSaving = true);
    var saved = false;
    try {
      await ExpenseDatabase.instance.insertExpense(
        title: _titleController.text.trim(),
        category: _category,
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate!,
        notes: _notesController.text.trim(),
      );
      saved = true;
    } catch (_) {
      saved = false;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(saved);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Expense saved successfully' : 'Failed to save expense',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expense title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter an expense title';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Select a category' : null,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              const Text(
                'Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null) return 'Enter a valid amount';
                  if (amount <= 0) return 'Amount must be greater than zero';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDate == null ? 'Select a date' : _selectedDate!,
                ),
                subtitle: const Text('Expense date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              const Text(
                'Notes (optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _confirmExpenseEntry,
                  child: Text(_isSaving ? 'Saving...' : 'Add expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
