import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/format.dart';

class CurrencyInput extends StatefulWidget {
  const CurrencyInput({
    super.key,
    required this.label,
    this.initialValue,
    this.onChanged,
    this.hint,
  });

  final String label;
  final double? initialValue;
  final ValueChanged<double>? onChanged;
  final String? hint;

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final init = widget.initialValue;
    _controller = TextEditingController(
      text: init != null && init > 0
          ? formatCurrencyInput(init.round().toString())
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final formatted = formatCurrencyInput(value);
    if (formatted != value) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    widget.onChanged?.call(parseCurrencyInput(formatted));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? '0',
        prefixText: 'LKR ',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
      ],
      onChanged: _onChanged,
    );
  }
}
