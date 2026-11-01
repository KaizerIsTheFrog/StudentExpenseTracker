import 'package:flutter/material.dart';

import 'expense_database.dart';
import 'addexpense.dart';
import 'editexpense.dart';

/// Shows saved expense records and opens the forms for adding or editing.
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const int _pageSize = 10;

  List<Map<String, Object?>> _expenses = [];
  bool _isLoading = true;
  bool _loadFailed = false;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    // Load existing entries as soon as the home screen appears.
    _loadExpenses();
  }

  // Read one page from SQLite and update the list or show an error state.
  Future<void> _loadExpenses({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
      _currentPage = page;
    });

    try {
      final expenseCount = await ExpenseDatabase.instance.getExpenseCount();
      final totalPages = (expenseCount / _pageSize).ceil().clamp(1, 1 << 31);
      final targetPage = page.clamp(1, totalPages);
      final expenses = await ExpenseDatabase.instance.getExpenses(
        limit: _pageSize,
        offset: (targetPage - 1) * _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _expenses = expenses;
        _isLoading = false;
        _currentPage = targetPage;
        _totalPages = totalPages;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _openAddExpensePage() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (context) => const AddExpensePage()),
    );
    // The form returns true only after a successful insert.
    if (saved == true) await _loadExpenses(page: 1);
  }

  Future<void> _openEditExpensePage(Map<String, Object?> expense) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => EditExpensePage(expense: expense),
      ),
    );
    // The form returns true only after a successful update.
    if (updated == true) await _loadExpenses(page: _currentPage);
  }

  Future<void> _confirmDeleteExpense(Map<String, Object?> expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This expense record will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final deleted = await ExpenseDatabase.instance.deleteExpense(
        expense['id'] as int,
      );
      if (!mounted) return;
      // Recalculate total pages; clamp to the nearest valid page if we were
      // on the last page and it became empty.
      await _loadExpenses(page: _currentPage);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            deleted > 0
                ? 'Expense deleted successfully'
                : 'Expense could not be deleted',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to delete expense')),
      );
    }
  }

  void _showExpenseDetails(Map<String, Object?> expense) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense['title'] as String),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Category', expense['category'] as String),
              _detailRow(
                'Amount',
                (expense['amount'] as num).toDouble().toStringAsFixed(2),
              ),
              _detailRow('Date', expense['date'] as String),
              _detailRow(
                'Notes',
                (expense['notes'] as String).isEmpty
                    ? 'No notes'
                    : expense['notes'] as String,
              ),
              const SizedBox(height: 8),
              const Text(
                'Saved:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(expense['created_at'] as String),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openEditExpensePage(expense);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Expense Tracker'),
        actions: [
          IconButton(
            tooltip: 'Refresh expenses',
            onPressed: _isLoading
                ? null
                : () => _loadExpenses(page: _currentPage),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (!_isLoading && !_loadFailed && _expenses.isNotEmpty)
            _buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpensePage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous page',
              onPressed: _currentPage > 1 && !_isLoading
                  ? () => _loadExpenses(page: _currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page $_currentPage of $_totalPages'),
            IconButton(
              tooltip: 'Next page',
              onPressed: _currentPage < _totalPages && !_isLoading
                  ? () => _loadExpenses(page: _currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_loadFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load expenses.'),
            TextButton(
              onPressed: () => _loadExpenses(page: _currentPage),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_expenses.isEmpty) {
      return const Center(child: Text('No expense records yet.'));
    }

    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        final amount = (expense['amount'] as num).toDouble();

        return ListTile(
          onTap: () => _showExpenseDetails(expense),
          onLongPress: () => _confirmDeleteExpense(expense),
          leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
          title: Text(expense['title'] as String),
          subtitle: Text(expense['category'] as String),
          trailing: Text(
            '- RM${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}
