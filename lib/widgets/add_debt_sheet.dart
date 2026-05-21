import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_card_rounded,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Add debt',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Account name'),
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'credit_card',
                label: Text('Credit card'),
                icon: Icon(Icons.credit_card_rounded, size: 18),
              ),
              ButtonSegment(
                value: 'loan',
                label: Text('Loan'),
                icon: Icon(Icons.account_balance_rounded, size: 18),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 14),
          CurrencyInput(
            label: _type == 'credit_card' ? 'Credit limit' : 'Original amount',
            onChanged: (v) => _limit = v,
          ),
          const SizedBox(height: 10),
          CurrencyInput(
            label: 'Current balance',
            onChanged: (v) => _balance = v,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Text('Add account'),
          ),
        ],
      ),
    );
  }
}
