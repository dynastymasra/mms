import 'package:flutter/material.dart';
import '../../../core/model/inventory_item_model.dart';
import '../../../core/model/item_type_model.dart';

/// Shows a dialog listing distinct name+brand+type combinations from inbound items.
/// Pass [filterTypeId] to scope the list to a single item type.
/// Returns the selected [InventoryItemModel] to prefill the stock-out form.
Future<InventoryItemModel?> showStockOutPickerDialog(
  BuildContext context, {
  required List<InventoryItemModel> allItems,
  String? filterTypeId,
}) {
  return showDialog<InventoryItemModel>(
    context: context,
    builder: (_) => _StockOutPickerDialog(
      allItems: allItems,
      filterTypeId: filterTypeId,
    ),
  );
}

class _StockOutPickerDialog extends StatefulWidget {
  const _StockOutPickerDialog({required this.allItems, this.filterTypeId});
  final List<InventoryItemModel> allItems;
  final String? filterTypeId;

  @override
  State<_StockOutPickerDialog> createState() => _StockOutPickerDialogState();
}

class _StockOutPickerDialogState extends State<_StockOutPickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  /// Deduplicated inbound entries by brand+typeId, keeping the most recent.
  late final List<InventoryItemModel> _inboundItems;
  List<InventoryItemModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    final seen = <String>{};
    final deduped = <InventoryItemModel>[];
    // Sort newest first so we keep the most recent entry per name+brand+type
    final sorted = [...widget.allItems]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    for (final item in sorted) {
      if (item.direction != InventoryDirection.inbound) continue;
      if (widget.filterTypeId != null && item.itemType.id != widget.filterTypeId) continue;
      final key = '${item.name.trim().toLowerCase()}__${item.brand.toLowerCase()}__${item.itemType.id}';
      if (seen.add(key)) deduped.add(item);
    }
    _inboundItems = deduped;
    _filtered = List.of(_inboundItems);
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _query = q;
      _filtered = q.isEmpty
          ? List.of(_inboundItems)
          : _inboundItems
              .where((e) =>
                  e.name.toLowerCase().contains(q) ||
                  e.brand.toLowerCase().contains(q) ||
                  e.itemType.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
          constraints: const BoxConstraints(maxHeight: 580),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colorScheme),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: _buildSearch(colorScheme),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _buildList(colorScheme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.error,
            colorScheme.error.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_upward_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock Out',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Select item to take out',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ColorScheme colorScheme) {
    return TextField(
      controller: _searchCtrl,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search brand or type...',
        prefixIcon: Icon(Icons.search_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.4)),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 18),
                onPressed: _searchCtrl.clear,
              )
            : null,
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.12)),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildList(ColorScheme colorScheme) {
    if (_filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Text(
                _inboundItems.isEmpty
                    ? 'No stock in records found'
                    : 'No matching items',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _filtered.length,
      separatorBuilder: (_, i) => Divider(
        height: 1,
        color: colorScheme.onSurface.withValues(alpha: 0.08),
      ),
      itemBuilder: (_, i) {
        final item = _filtered[i];
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(item),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.15),
                          colorScheme.primary.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        item.itemType.unit.symbol,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.brand}  ·  ${item.itemType.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 16, color: colorScheme.error),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
