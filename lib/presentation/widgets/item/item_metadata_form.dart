import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/item.dart';

/// Form widget for editing item metadata (quantity, notes, expiration date)
class ItemMetadataForm extends StatefulWidget {

  const ItemMetadataForm({super.key, this.item, required this.onSubmit});
  final Item? item;
  final Function(int quantity, String? notes, DateTime? expirationDate)
  onSubmit;

  @override
  State<ItemMetadataForm> createState() => _ItemMetadataFormState();
}

class _ItemMetadataFormState extends State<ItemMetadataForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late final TextEditingController _expirationDateController;
  DateTime? _selectedExpirationDate;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _quantityController = TextEditingController(
      text: (widget.item?.quantity ?? 1).toString(),
    );
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _expirationDateController = TextEditingController(
      text: widget.item?.expirationDate != null
          ? _formatDate(widget.item!.expirationDate!)
          : '',
    );
    _selectedExpirationDate = widget.item?.expirationDate;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null && picked != _selectedExpirationDate) {
      setState(() {
        _selectedExpirationDate = picked;
        _expirationDateController.text = _formatDate(picked);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final notes = _notesController.text.isEmpty
          ? null
          : _notesController.text;

      widget.onSubmit(quantity, notes, _selectedExpirationDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Quantity Field
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity < 1) {
                    return 'Quantity must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any notes or description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Notes must be less than 500 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiration Date Field
              TextFormField(
                controller: _expirationDateController,
                decoration: InputDecoration(
                  labelText: 'Expiration Date',
                  hintText: 'Select expiration date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectExpirationDate,
                  ),
                ),
                readOnly: true,
                onTap: _selectExpirationDate,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Save Metadata'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
