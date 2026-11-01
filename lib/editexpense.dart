import 'package:flutter/material.dart';

import 'expense_database.dart';

/// Edits an existing expense record with prefilled form values.
class EditExpensePage extends StatefulWidget {
  final Map<String, Object?> expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late String _category;
  late String _selectedDate;
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
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.expense['title'] as String,
    );
    _amountController = TextEditingController(
      text: (widget.expense['amount'] as num).toStringAsFixed(2),
    );
    _notesController = TextEditingController(
      text: widget.expense['notes'] as String? ?? '',
    );
    _category = widget.expense['category'] as String;
    _selectedDate = widget.expense['date'] as String;
  }

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
      initialDate: DateTime.tryParse(_selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _confirmUpdate() async {
    // Do not ask for confirmation until required fields pass validation.
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm update'),
        content: const Text('Save changes to this expense record?'),
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

    setState(() => _isSaving = true);
    var updated = false;
    try {
      await ExpenseDatabase.instance.updateExpense(
        id: widget.expense['id'] as int,
        title: _titleController.text.trim(),
        category: _category,
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        notes: _notesController.text.trim(),
      );
      updated = true;
    } catch (_) {
      updated = false;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(updated);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          updated ? 'Expense updated successfully' : 'Failed to update expense',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
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
                title: Text(_selectedDate),
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
                  onPressed: _isSaving ? null : _confirmUpdate,
                  child: Text(_isSaving ? 'Saving...' : 'Update expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
