import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/item_type_repository.dart';
import '../../../core/model/inventory_item_model.dart';
import '../../../core/model/item_type_model.dart';

class InventoryFormDialog extends StatefulWidget {
  const InventoryFormDialog({
    super.key,
    this.item,
    this.lockedDirection,
    this.lockedName,
    this.lockedBrand,
    this.lockedBarcode,
    this.lockedType,
    this.maxStockQty,
  });

  final InventoryItemModel? item;

  /// When set, the direction toggle is hidden and this value is used.
  final InventoryDirection? lockedDirection;

  /// When set, the name field is pre-filled and read-only.
  final String? lockedName;

  /// When set, the brand field is pre-filled and read-only.
  final String? lockedBrand;

  /// When set, the barcode field is pre-filled and read-only.
  final String? lockedBarcode;

  /// When set, the type dropdown is pre-selected and read-only.
  final ItemTypeModel? lockedType;

  /// When set (stock-out), quantity cannot exceed this value.
  final double? maxStockQty;

  @override
  State<InventoryFormDialog> createState() => _InventoryFormDialogState();
}

class _InventoryFormDialogState extends State<InventoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _descCtrl;

  final _itemTypes = ItemTypeRepository().all;

  late ItemTypeModel _selectedType;
  late InventoryDirection _direction;
  late DateTime _timestamp;

  bool get _isEdit => widget.item != null;
  bool get _nameLocked => widget.lockedName != null;
  bool get _brandLocked => widget.lockedBrand != null;
  bool get _barcodeLocked => widget.lockedBarcode != null;
  bool get _typeLocked => widget.lockedType != null;
  bool get _directionLocked => widget.lockedDirection != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: widget.lockedName ?? item?.name ?? '');
    _brandCtrl = TextEditingController(
        text: widget.lockedBrand ?? item?.brand ?? '');
    _barcodeCtrl = TextEditingController(
        text: widget.lockedBarcode ?? item?.barcode ?? '');
    _quantityCtrl = TextEditingController(
      text: item != null ? _formatQty(item.quantity) : '',
    );
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _selectedType =
        widget.lockedType ?? item?.itemType ?? _itemTypes.first;
    _direction =
        widget.lockedDirection ?? item?.direction ?? InventoryDirection.inbound;
    _timestamp = item?.timestamp ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _barcodeCtrl.dispose();
    _quantityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _formatQty(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _pickTimestamp() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _timestamp = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 0;
    Navigator.of(context).pop((
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      barcode: _barcodeCtrl.text.trim(),
      itemType: _selectedType,
      quantity: qty,
      timestamp: _timestamp,
      direction: _direction,
      description: _descCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 480,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colorScheme),
                  const SizedBox(height: 24),
                  if (!_directionLocked) ...[
                    _buildDirectionToggle(colorScheme),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildDirectionBadge(colorScheme),
                    const SizedBox(height: 16),
                  ],
                  _buildNameField(colorScheme),
                  const SizedBox(height: 16),
                  _buildBrandField(colorScheme),
                  const SizedBox(height: 16),
                  _buildBarcodeField(colorScheme),
                  const SizedBox(height: 16),
                  _buildTypeField(colorScheme),
                  const SizedBox(height: 16),
                  _buildTextField(
                    colorScheme,
                    controller: _quantityCtrl,
                    label: 'Quantity (${_selectedType.unit.symbol})',
                    icon: Icons.numbers_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Quantity is required';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Enter a valid quantity';
                      final max = widget.maxStockQty;
                      if (max != null && n > max) {
                        return 'Exceeds available stock ($max ${_selectedType.unit.symbol})';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTimestampField(colorScheme),
                  const SizedBox(height: 16),
                  _buildTextField(
                    colorScheme,
                    controller: _descCtrl,
                    label: 'Description (optional)',
                    icon: Icons.notes_rounded,
                    validator: (_) => null,
                    capitalization: TextCapitalization.sentences,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),
                  _buildActions(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final isIn = _direction == InventoryDirection.inbound;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isEdit
                ? Icons.edit_rounded
                : isIn
                    ? Icons.add_box_rounded
                    : Icons.move_to_inbox_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          _isEdit
              ? 'Edit Inventory Item'
              : isIn
                  ? 'Stock In'
                  : 'Stock Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildDirectionBadge(ColorScheme colorScheme) {
    final isIn = _direction == InventoryDirection.inbound;
    final color = isIn ? Colors.green.shade600 : colorScheme.error;
    return Row(
      children: [
        Text(
          'Direction',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isIn
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                _direction.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          'Direction',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 16),
        ...InventoryDirection.values.map((d) {
          final selected = _direction == d;
          final isIn = d == InventoryDirection.inbound;
          final color = isIn ? Colors.green.shade600 : colorScheme.error;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _direction = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.12)
                      : colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? color
                        : colorScheme.onSurface.withValues(alpha: 0.12),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIn
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 16,
                      color: selected
                          ? color
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      d.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? color
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNameField(ColorScheme colorScheme) {
    if (_nameLocked) {
      return _buildReadOnlyField(
        colorScheme,
        label: 'Name',
        value: _nameCtrl.text.isEmpty ? '–' : _nameCtrl.text,
        icon: Icons.drive_file_rename_outline_rounded,
      );
    }
    return _buildTextField(
      colorScheme,
      controller: _nameCtrl,
      label: 'Name',
      icon: Icons.drive_file_rename_outline_rounded,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Name is required' : null,
      capitalization: TextCapitalization.words,
    );
  }

  Widget _buildBarcodeField(ColorScheme colorScheme) {
    if (_barcodeLocked || _direction == InventoryDirection.outbound) {
      return _buildReadOnlyField(
        colorScheme,
        label: 'Barcode',
        value: _barcodeCtrl.text.isEmpty ? '–' : _barcodeCtrl.text,
        icon: Icons.qr_code_rounded,
      );
    }
    return _buildTextField(
      colorScheme,
      controller: _barcodeCtrl,
      label: 'Barcode (optional)',
      icon: Icons.qr_code_rounded,
      validator: (_) => null,
    );
  }

  Widget _buildBrandField(ColorScheme colorScheme) {
    final isReadOnly =
        _brandLocked || _direction == InventoryDirection.outbound;
    if (isReadOnly) {
      return _buildReadOnlyField(
        colorScheme,
        label: 'Brand',
        value: _brandCtrl.text.isEmpty ? '–' : _brandCtrl.text,
        icon: Icons.label_outline_rounded,
      );
    }
    return _buildTextField(
      colorScheme,
      controller: _brandCtrl,
      label: 'Brand',
      icon: Icons.label_outline_rounded,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Brand is required' : null,
      capitalization: TextCapitalization.words,
    );
  }

  Widget _buildTypeField(ColorScheme colorScheme) {
    if (_typeLocked) {
      return _buildReadOnlyField(
        colorScheme,
        label: 'Item Type',
        value: '${_selectedType.name}  (${_selectedType.unit.symbol})',
        icon: Icons.category_outlined,
      );
    }
    return _buildTypeDropdown(colorScheme);
  }

  Widget _buildReadOnlyField(
    ColorScheme colorScheme, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.35)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.lock_outline_rounded,
              size: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.25)),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.12)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ItemTypeModel>(
              value: _selectedType,
              isExpanded: true,
              icon: Icon(Icons.expand_more_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.5)),
              items: _itemTypes
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.unit.symbol,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(t.name),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampField(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _pickTimestamp,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timestamp',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_timestamp.day.toString().padLeft(2, '0')}/'
                  '${_timestamp.month.toString().padLeft(2, '0')}/'
                  '${_timestamp.year}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_calendar_rounded,
                size: 18,
                color: colorScheme.primary.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    ColorScheme colorScheme, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextCapitalization capitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: capitalization,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,
            color: colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.2)),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_isEdit ? 'Save Changes' : 'Confirm'),
          ),
        ),
      ],
    );
  }
}
