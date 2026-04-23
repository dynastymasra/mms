import 'package:flutter/material.dart';
import '../../../core/model/inventory_item_model.dart';
import '../../../core/model/item_type_model.dart';
import '../../../core/session/session_manager.dart';
import '../../admin/view/settings/settings_widgets.dart';
import '../viewmodel/inventory_viewmodel.dart';
import 'inventory_form_dialog.dart';
import 'stock_out_picker_dialog.dart';

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen>
    with SingleTickerProviderStateMixin {
  final InventoryViewModel _vm = InventoryViewModel();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _vm.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _vm.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openStockIn({
    String? lockedName,
    String? lockedBrand,
    String? lockedBarcode,
    ItemTypeModel? lockedType,
  }) async {
    await _openForm(
      lockedDirection: InventoryDirection.inbound,
      lockedName: lockedName,
      lockedBrand: lockedBrand,
      lockedBarcode: lockedBarcode,
      lockedType: lockedType,
    );
  }

  Future<void> _openStockOutForType(ItemTypeModel type) async {
    final picked = await showStockOutPickerDialog(
      context,
      allItems: _vm.allItems,
      filterTypeId: type.id,
    );
    if (picked == null) return;
    final maxQty = _vm.netStockFor(picked.name, picked.brand, picked.itemType.id);
    await _openForm(
      lockedDirection: InventoryDirection.outbound,
      lockedName: picked.name,
      lockedType: picked.itemType,
      lockedBrand: picked.brand,
      lockedBarcode: picked.barcode,
      maxStockQty: maxQty,
    );
  }

  Future<void> _openStockOut() async {
    final picked = await showStockOutPickerDialog(
      context,
      allItems: _vm.allItems,
    );
    if (picked == null) return;
    final maxQty = _vm.netStockFor(picked.name, picked.brand, picked.itemType.id);
    await _openForm(
      lockedDirection: InventoryDirection.outbound,
      lockedName: picked.name,
      lockedType: picked.itemType,
      lockedBrand: picked.brand,
      lockedBarcode: picked.barcode,
      maxStockQty: maxQty,
    );
  }

  Future<void> _openForm({
    InventoryItemModel? item,
    InventoryDirection? lockedDirection,
    String? lockedName,
    String? lockedBrand,
    String? lockedBarcode,
    ItemTypeModel? lockedType,
    double? maxStockQty,
  }) async {
    final result = await showDialog<
        ({
          String name,
          String brand,
          String barcode,
          ItemTypeModel itemType,
          double quantity,
          DateTime timestamp,
          InventoryDirection direction,
          String description,
        })>(
      context: context,
      builder: (_) => InventoryFormDialog(
        item: item,
        lockedDirection: lockedDirection,
        lockedName: lockedName,
        lockedBrand: lockedBrand,
        lockedBarcode: lockedBarcode,
        lockedType: lockedType,
        maxStockQty: maxStockQty,
      ),
    );
    if (result == null) return;

    final currentUser = SessionManager().currentUser!;

    if (item == null) {
      _vm.add(
        name: result.name,
        brand: result.brand,
        barcode: result.barcode,
        itemType: result.itemType,
        quantity: result.quantity,
        timestamp: result.timestamp,
        handledBy: currentUser,
        direction: result.direction,
        description: result.description,
      );
    } else {
      _vm.update(item.copyWith(
        name: result.name,
        brand: result.brand,
        barcode: result.barcode,
        itemType: result.itemType,
        quantity: result.quantity,
        timestamp: result.timestamp,
        direction: result.direction,
        description: result.description,
      ));
    }
  }

  Future<void> _confirmDelete(InventoryItemModel item) async {
    final confirmed = await showSettingsDeleteConfirm(
        context, '${item.brand} (${item.itemType.name})');
    if (confirmed == true) _vm.remove(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              const Color(0xFFF0F7F0),
              Colors.white,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(colorScheme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CurrentStockTab(
                    vm: _vm,
                    onStockOutForType: (type) => _openStockOutForType(type),
                    onStockOut: _openStockOut,
                    onStockIn: ({ItemTypeModel? type}) =>
                        _openStockIn(lockedType: type),
                  ),
                  _HistoryTab(
                    vm: _vm,
                    onStockIn: () => _openStockIn(),
                    onStockOut: _openStockOut,
                    onEdit: (item) => _openForm(item: item),
                    onDelete: _confirmDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
            const Color(0xFF2E7D32),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Inventory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(Icons.layers_rounded, size: 18),
                  text: 'Current Stock',
                  iconMargin: EdgeInsets.only(bottom: 2),
                ),
                Tab(
                  icon: Icon(Icons.history_rounded, size: 18),
                  text: 'History',
                  iconMargin: EdgeInsets.only(bottom: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Current Stock tab ─────────────────────────────────────────────────────────

class _CurrentStockTab extends StatefulWidget {
  const _CurrentStockTab({
    required this.vm,
    required this.onStockOutForType,
    required this.onStockOut,
    required this.onStockIn,
  });

  final InventoryViewModel vm;
  final void Function(ItemTypeModel type) onStockOutForType;
  final VoidCallback onStockOut;
  final void Function({ItemTypeModel? type}) onStockIn;

  @override
  State<_CurrentStockTab> createState() => _CurrentStockTabState();
}

class _CurrentStockTabState extends State<_CurrentStockTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _selectedTypeId;

  List<_StockEntry> get _stock {
    final all = widget.vm.allItems;
    final map = <String, _StockEntry>{};
    for (final item in all) {
      final key = item.itemType.id;
      final entry = map.putIfAbsent(
        key,
        () => _StockEntry(itemType: item.itemType),
      );
      if (item.direction == InventoryDirection.inbound) {
        entry.netStock += item.quantity;
      } else {
        entry.netStock -= item.quantity;
      }
    }

    var entries = map.values.toList()
      ..sort((a, b) => a.itemType.name.compareTo(b.itemType.name));

    if (_selectedTypeId != null) {
      entries =
          entries.where((e) => e.itemType.id == _selectedTypeId).toList();
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      entries = entries
          .where((e) =>
              e.itemType.name.toLowerCase().contains(q) ||
              e.itemType.unit.label.toLowerCase().contains(q))
          .toList();
    }

    return entries;
  }

  List<ItemTypeModel> get _availableTypes {
    final all = widget.vm.allItems;
    final seen = <String>{};
    final result = <ItemTypeModel>[];
    for (final item in all) {
      if (seen.add(item.itemType.id)) result.add(item.itemType);
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stock = _stock;
    final types = _availableTypes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        children: [
          _buildToolbar(colorScheme),
          const SizedBox(height: 14),
          if (types.isNotEmpty) ...[
            _buildTypeChips(types, colorScheme),
            const SizedBox(height: 14),
          ],
          Expanded(
            child: stock.isEmpty
                ? _buildEmpty(colorScheme)
                : _buildTable(stock, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(child: _SearchBox(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v.trim()))),
        const SizedBox(width: 12),
        _GradientButton(
          label: 'Stock In',
          icon: Icons.arrow_downward_rounded,
          colors: [Colors.green.shade500, Colors.green.shade700],
          onTap: () => widget.onStockIn(),
        ),
        const SizedBox(width: 8),
        _GradientButton(
          label: 'Stock Out',
          icon: Icons.arrow_upward_rounded,
          colors: [Colors.red.shade400, Colors.red.shade700],
          onTap: widget.onStockOut,
        ),
      ],
    );
  }

  Widget _buildTypeChips(List<ItemTypeModel> types, ColorScheme colorScheme) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _TypeChip(
            label: 'All',
            selected: _selectedTypeId == null,
            colorScheme: colorScheme,
            onTap: () => setState(() => _selectedTypeId = null),
          ),
          const SizedBox(width: 8),
          ...types.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TypeChip(
                  label: t.name,
                  selected: _selectedTypeId == t.id,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _selectedTypeId = t.id),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.08),
                  colorScheme.primary.withValues(alpha: 0.04),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.layers_rounded,
                size: 52, color: colorScheme.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text(
            'No stock data yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add items using Stock In',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<_StockEntry> stock, ColorScheme colorScheme) {
    return SettingsDataTable(
      headers: const ['#', 'Type', 'Total Stock', ''],
      flexes: const [1, 4, 4, 2],
      itemCount: stock.length,
      rowBuilder: (i) => _buildStockRow(i, stock[i], colorScheme),
    );
  }

  List<Widget> _buildStockRow(int i, _StockEntry entry, ColorScheme colorScheme) {
    final net = entry.netStock;
    final netStr = net == net.truncateToDouble()
        ? net.toInt().toString()
        : net.toString();
    final netColor = net > 0
        ? Colors.green.shade600
        : net < 0
            ? colorScheme.error
            : colorScheme.onSurface.withValues(alpha: 0.4);

    return [
      Text(
        '${i + 1}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                colorScheme.primary.withValues(alpha: 0.15),
                colorScheme.primary.withValues(alpha: 0.06),
              ]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.category_rounded,
                size: 16, color: colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Text(
            entry.itemType.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                netColor.withValues(alpha: 0.15),
                netColor.withValues(alpha: 0.06),
              ]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: netColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  netStr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: netColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.itemType.unit.symbol,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: netColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Stock In',
            child: InkWell(
              onTap: () => widget.onStockIn(type: entry.itemType),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.green.shade600.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.green.shade600.withValues(alpha: 0.25)),
                ),
                child: Icon(Icons.arrow_downward_rounded,
                    size: 16, color: Colors.green.shade600),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: 'Stock Out',
            child: InkWell(
              onTap: () => widget.onStockOutForType(entry.itemType),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.25)),
                ),
                child: Icon(Icons.arrow_upward_rounded,
                    size: 16, color: colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}

class _StockEntry {
  _StockEntry({required this.itemType});
  final ItemTypeModel itemType;
  double netStock = 0;
}

// ── History tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends StatefulWidget {
  const _HistoryTab({
    required this.vm,
    required this.onStockIn,
    required this.onStockOut,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryViewModel vm;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;
  final void Function(InventoryItemModel) onEdit;
  final void Function(InventoryItemModel) onDelete;

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  final _searchCtrl = TextEditingController();
  String? _selectedTypeId;

  List<ItemTypeModel> get _availableTypes {
    final seen = <String>{};
    final result = <ItemTypeModel>[];
    for (final item in widget.vm.allItems) {
      if (seen.add(item.itemType.id)) result.add(item.itemType);
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => widget.vm.search(_searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = SessionManager().currentUser!.id;

    final items = _selectedTypeId == null
        ? widget.vm.items
        : widget.vm.items
            .where((e) => e.itemType.id == _selectedTypeId)
            .toList();

    final types = _availableTypes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        children: [
          _buildToolbar(colorScheme),
          const SizedBox(height: 14),
          if (types.isNotEmpty) ...[
            _buildTypeChips(types, colorScheme),
            const SizedBox(height: 14),
          ],
          Expanded(
            child: items.isEmpty
                ? _buildEmpty(colorScheme)
                : SettingsDataTable(
                    headers: const [
                      '#', 'Name', 'Brand', 'Barcode', 'Type',
                      'Qty', 'Date', 'Handled By', 'Description', 'Dir', '',
                    ],
                    flexes: const [1, 2, 2, 2, 2, 2, 2, 2, 3, 1, 2],
                    itemCount: items.length,
                    rowBuilder: (i) => _buildHistoryRow(
                        i, items[i], colorScheme, currentUserId),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: SettingsSearchField(
            controller: _searchCtrl,
            hint: 'Search name, brand, type, handler...',
          ),
        ),
        const SizedBox(width: 12),
        _GradientButton(
          label: 'Stock In',
          icon: Icons.arrow_downward_rounded,
          colors: [Colors.green.shade500, Colors.green.shade700],
          onTap: widget.onStockIn,
        ),
        const SizedBox(width: 8),
        _GradientButton(
          label: 'Stock Out',
          icon: Icons.arrow_upward_rounded,
          colors: [Colors.red.shade400, Colors.red.shade700],
          onTap: widget.onStockOut,
        ),
      ],
    );
  }

  Widget _buildTypeChips(List<ItemTypeModel> types, ColorScheme colorScheme) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _TypeChip(
            label: 'All',
            selected: _selectedTypeId == null,
            colorScheme: colorScheme,
            onTap: () => setState(() => _selectedTypeId = null),
          ),
          const SizedBox(width: 8),
          ...types.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TypeChip(
                  label: t.name,
                  selected: _selectedTypeId == t.id,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _selectedTypeId = t.id),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                colorScheme.primary.withValues(alpha: 0.08),
                colorScheme.primary.withValues(alpha: 0.04),
              ]),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded,
                size: 52, color: colorScheme.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHistoryRow(
    int i,
    InventoryItemModel item,
    ColorScheme colorScheme,
    String currentUserId,
  ) {
    final isIn = item.direction == InventoryDirection.inbound;
    final dirColor = isIn ? Colors.green.shade600 : colorScheme.error;
    final d = item.timestamp;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final qtyStr = item.quantity == item.quantity.truncateToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toString();
    final canEdit = !isIn || item.handledBy.id == currentUserId;

    return [
      Text(
        '${i + 1}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      Text(
        item.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontSize: 13,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        item.brand,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      item.barcode.isEmpty
          ? Text('–',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurface.withValues(alpha: 0.28),
              ))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_rounded,
                    size: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    item.barcode,
                    style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      Text(
        item.itemType.name,
        style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
        overflow: TextOverflow.ellipsis,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            qtyStr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              item.itemType.unit.symbol,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      Text(
        dateStr,
        style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.65)),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              item.handledBy.displayInitials,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              item.handledBy.name,
              style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.7)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      Text(
        item.description.isEmpty ? '–' : item.description,
        style: TextStyle(
          fontSize: 11,
          color: item.description.isEmpty
              ? colorScheme.onSurface.withValues(alpha: 0.28)
              : colorScheme.onSurface.withValues(alpha: 0.65),
          fontStyle: item.description.isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      Tooltip(
        message: item.direction.label,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              dirColor.withValues(alpha: 0.15),
              dirColor.withValues(alpha: 0.06),
            ]),
            shape: BoxShape.circle,
            border: Border.all(color: dirColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(
            isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            size: 13,
            color: dirColor,
          ),
        ),
      ),
      canEdit
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SettingsActionIcon(
                  icon: Icons.edit_rounded,
                  color: colorScheme.primary,
                  tooltip: 'Edit',
                  onTap: () => widget.onEdit(item),
                ),
                SettingsActionIcon(
                  icon: Icons.delete_rounded,
                  color: colorScheme.error,
                  tooltip: 'Delete',
                  onTap: () => widget.onDelete(item),
                ),
              ],
            )
          : Tooltip(
              message: 'Added by ${item.handledBy.name}',
              child: Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ),
    ];
  }
}

// ── Shared UI components ──────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Tooltip(
            message: label,
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search type...',
        hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.35), fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.35), size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                    size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.12)),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
