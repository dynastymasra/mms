import '../model/inventory_item_model.dart';

class InventoryRepository {
  InventoryRepository._();
  static final InventoryRepository instance = InventoryRepository._();
  factory InventoryRepository() => instance;

  final List<InventoryItemModel> _items = [];

  List<InventoryItemModel> get all => List.unmodifiable(_items);

  void add(InventoryItemModel item) => _items.add(item);

  void update(InventoryItemModel updated) {
    final i = _items.indexWhere((e) => e.id == updated.id);
    if (i != -1) _items[i] = updated;
  }

  void remove(String id) => _items.removeWhere((e) => e.id == id);

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
