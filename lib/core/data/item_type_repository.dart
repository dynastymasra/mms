import '../model/item_type_model.dart';

class ItemTypeRepository {
  ItemTypeRepository._();
  static final ItemTypeRepository instance = ItemTypeRepository._();
  factory ItemTypeRepository() => instance;

  final List<ItemTypeModel> _types = [
    const ItemTypeModel(id: '1', name: 'Mineral Water (2L)',    unit: ItemUnit.bottle),
    const ItemTypeModel(id: '2', name: 'Mineral Water (500mL)', unit: ItemUnit.bottle),
    const ItemTypeModel(id: '3', name: 'Beverage (1L)',         unit: ItemUnit.bottle),
    const ItemTypeModel(id: '4', name: 'Beverage (500mL)',      unit: ItemUnit.bottle),
    const ItemTypeModel(id: '5', name: 'Toilet Paper',          unit: ItemUnit.piece),
    const ItemTypeModel(id: '6', name: 'Tea (Box)',             unit: ItemUnit.box),
  ];

  List<ItemTypeModel> get all => List.unmodifiable(_types);

  void add(ItemTypeModel type) => _types.add(type);

  void update(ItemTypeModel updated) {
    final i = _types.indexWhere((t) => t.id == updated.id);
    if (i != -1) _types[i] = updated;
  }

  void remove(String id) => _types.removeWhere((t) => t.id == id);

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
