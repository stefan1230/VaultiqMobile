import 'package:flutter/material.dart';

import 'currency_input.dart';

class AddDebtSheet extends StatefulWidget {
  const AddDebtSheet({super.key, required this.onSubmit});

  final Future<void> Function({
    required String name,
    required String type,
    required double limit,
    required double currentBalance,
  }) onSubmit;

  @override
  State<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<AddDebtSheet> {
  final _nameCtrl = TextEditingController();
  String _type = 'credit_card';
  double _limit = 0;
  double _balance = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    await widget.onSubmit(
      name: _nameCtrl.text,
      type: _type,
      limit: _limit,
      currentBalance: _balance,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add debt',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Account name'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'credit_card', label: Text('Credit card')),
              ButtonSegment(value: 'loan', label: Text('Loan')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 12),
          CurrencyInput(
            label: _type == 'credit_card' ? 'Credit limit' : 'Original amount',
            onChanged: (v) => _limit = v,
          ),
          const SizedBox(height: 8),
          CurrencyInput(
            label: 'Current balance',
            onChanged: (v) => _balance = v,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: const Text('Add account'),
          ),
        ],
      ),
    );
  }
}
