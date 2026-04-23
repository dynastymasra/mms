import 'package:flutter/foundation.dart';
import '../../../core/data/inventory_repository.dart';
import '../../../core/model/inventory_item_model.dart';
import '../../../core/model/item_type_model.dart';
import '../../../core/model/user_model.dart';

class InventoryViewModel extends ChangeNotifier {
  final _repo = InventoryRepository();

  List<InventoryItemModel> _all = [];
  List<InventoryItemModel> _filtered = [];
  String _query = '';
  String? _selectedTypeId; // null = show all

  List<InventoryItemModel> get items => _filtered;
  List<InventoryItemModel> get allItems => List.of(_all);
  String? get selectedTypeId => _selectedTypeId;

  /// Distinct item types present in the current data, ordered by name.
  List<ItemTypeModel> get availableTypes {
    final seen = <String>{};
    final result = <ItemTypeModel>[];
    for (final item in _all) {
      if (seen.add(item.itemType.id)) result.add(item.itemType);
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  InventoryViewModel() {
    _reload();
  }

  void _reload() {
    _all = _repo.all.toList();
    _applyFilter();
  }

  void _applyFilter() {
    var list = _all;

    if (_selectedTypeId != null) {
      list = list.where((e) => e.itemType.id == _selectedTypeId).toList();
    }

    final q = _query.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.brand.toLowerCase().contains(q) ||
              e.barcode.toLowerCase().contains(q) ||
              e.itemType.name.toLowerCase().contains(q) ||
              e.handledBy.name.toLowerCase().contains(q))
          .toList();
    }

    _filtered = list;
    notifyListeners();
  }

  void search(String query) {
    _query = query.trim();
    _applyFilter();
  }

  void filterByType(String? typeId) {
    _selectedTypeId = typeId;
    _applyFilter();
  }

  void add({
    required String name,
    required String brand,
    required String barcode,
    required ItemTypeModel itemType,
    required double quantity,
    required DateTime timestamp,
    required UserModel handledBy,
    required InventoryDirection direction,
    String description = '',
  }) {
    _repo.add(InventoryItemModel(
      id: _repo.generateId(),
      name: name.trim(),
      brand: brand.trim(),
      barcode: barcode.trim(),
      itemType: itemType,
      quantity: quantity,
      timestamp: timestamp,
      handledBy: handledBy,
      direction: direction,
      description: description.trim(),
    ));
    _reload();
  }

  /// Net stock for a specific name+brand+type combination.
  double netStockFor(String name, String brand, String typeId) {
    double net = 0;
    for (final e in _all) {
      if (e.name.trim().toLowerCase() == name.trim().toLowerCase() &&
          e.brand.trim().toLowerCase() == brand.trim().toLowerCase() &&
          e.itemType.id == typeId) {
        net += e.direction == InventoryDirection.inbound ? e.quantity : -e.quantity;
      }
    }
    return net;
  }

  void update(InventoryItemModel updated) {
    _repo.update(updated);
    _reload();
  }

  void remove(String id) {
    _repo.remove(id);
    _reload();
  }
}
