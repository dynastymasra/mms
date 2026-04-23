import 'package:flutter/material.dart';
import '../../../../core/model/item_type_model.dart';
import '../../viewmodel/item_type_viewmodel.dart';
import 'settings_widgets.dart';

class ItemTypeTab extends StatefulWidget {
  const ItemTypeTab({super.key});

  @override
  State<ItemTypeTab> createState() => _ItemTypeTabState();
}

class _ItemTypeTabState extends State<ItemTypeTab> {
  final ItemTypeViewModel _vm = ItemTypeViewModel();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.addListener(() { if (mounted) setState(() {}); });
    _searchCtrl.addListener(() => _vm.search(_searchCtrl.text));
  }

  @override
  void dispose() {
    _vm.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({ItemTypeModel? item}) async {
    final result = await showDialog<({String name, ItemUnit unit})>(
      context: context,
      builder: (_) => _ItemTypeFormDialog(item: item),
    );
    if (result == null) return;
    if (item == null) {
      _vm.add(name: result.name, unit: result.unit);
    } else {
      _vm.update(item.copyWith(name: result.name, unit: result.unit));
    }
  }

  Future<void> _confirmDelete(ItemTypeModel item) async {
    final confirmed = await showSettingsDeleteConfirm(context, item.name);
    if (confirmed == true) _vm.remove(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = _vm.items;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SettingsSearchField(
                  controller: _searchCtrl, hint: 'Search type...'),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: 'Add Type',
              child: FilledButton(
                onPressed: () => _openForm(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: items.isEmpty
              ? const SettingsEmptyState(
                  icon: Icons.category_rounded,
                  message: 'No item types found',
                )
              : SettingsDataTable(
                  headers: const ['#', 'Type Name', 'Unit', 'Symbol', ''],
                  flexes: const [1, 4, 3, 2, 2],
                  itemCount: items.length,
                  rowBuilder: (i) => [
                    Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      items[i].name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      items[i].unit.label,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        items[i].unit.symbol,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SettingsActionIcon(
                          icon: Icons.edit_rounded,
                          color: colorScheme.primary,
                          tooltip: 'Edit',
                          onTap: () => _openForm(item: items[i]),
                        ),
                        SettingsActionIcon(
                          icon: Icons.delete_rounded,
                          color: colorScheme.error,
                          tooltip: 'Delete',
                          onTap: () => _confirmDelete(items[i]),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── Item Type form dialog ─────────────────────────────────────────────────────

class _ItemTypeFormDialog extends StatefulWidget {
  const _ItemTypeFormDialog({this.item});

  final ItemTypeModel? item;

  @override
  State<_ItemTypeFormDialog> createState() => _ItemTypeFormDialogState();
}

class _ItemTypeFormDialogState extends State<_ItemTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late ItemUnit _unit;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name ?? '');
    _unit = widget.item?.unit ?? ItemUnit.piece;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((name: _nameCtrl.text.trim(), unit: _unit));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(32),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colorScheme),
                const SizedBox(height: 24),
                _buildNameField(colorScheme),
                const SizedBox(height: 16),
                _buildUnitSelector(colorScheme),
                const SizedBox(height: 28),
                _buildActions(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isEdit ? Icons.edit_rounded : Icons.category_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          _isEdit ? 'Edit Item Type' : 'Add Item Type',
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

  Widget _buildNameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _nameCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDeco(
        colorScheme,
        label: 'Type Name',
        icon: Icons.label_outline_rounded,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Name is required' : null,
    );
  }

  Widget _buildUnitSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit',
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
            child: DropdownButton<ItemUnit>(
              value: _unit,
              isExpanded: true,
              icon: Icon(Icons.expand_more_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.5)),
              items: ItemUnit.values
                  .map((u) => DropdownMenuItem(
                        value: u,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                u.symbol,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(u.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _unit = v);
              },
            ),
          ),
        ),
      ],
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
            child: Text(_isEdit ? 'Save Changes' : 'Add Type'),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(
    ColorScheme colorScheme, {
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
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
        borderSide:
            BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.12)),
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
    );
  }
}
