enum ItemUnit {
  liter,
  milliliter,
  kilogram,
  piece,
  box,
  bottle,
  pack,
  gram,
  milligram,
  meter,
  centimeter,
  set,
}

extension ItemUnitExtension on ItemUnit {
  String get label {
    switch (this) {
      case ItemUnit.liter:      return 'Liter';
      case ItemUnit.milliliter: return 'Milliliter';
      case ItemUnit.kilogram:   return 'Kilogram';
      case ItemUnit.piece:      return 'Piece';
      case ItemUnit.box:        return 'Box';
      case ItemUnit.bottle:     return 'Bottle';
      case ItemUnit.pack:       return 'Pack';
      case ItemUnit.gram:       return 'Gram';
      case ItemUnit.milligram:  return 'Milligram';
      case ItemUnit.meter:      return 'Meter';
      case ItemUnit.centimeter: return 'Centimeter';
      case ItemUnit.set:        return 'Set';
    }
  }

  String get symbol {
    switch (this) {
      case ItemUnit.liter:      return 'L';
      case ItemUnit.milliliter: return 'mL';
      case ItemUnit.kilogram:   return 'kg';
      case ItemUnit.piece:      return 'pcs';
      case ItemUnit.box:        return 'box';
      case ItemUnit.bottle:     return 'btl';
      case ItemUnit.pack:       return 'pack';
      case ItemUnit.gram:       return 'g';
      case ItemUnit.milligram:  return 'mg';
      case ItemUnit.meter:      return 'm';
      case ItemUnit.centimeter: return 'cm';
      case ItemUnit.set:        return 'set';
    }
  }
}

class ItemTypeModel {
  const ItemTypeModel({
    required this.id,
    required this.name,
    required this.unit,
  });

  final String id;
  final String name;
  final ItemUnit unit;

  ItemTypeModel copyWith({String? name, ItemUnit? unit}) =>
      ItemTypeModel(id: id, name: name ?? this.name, unit: unit ?? this.unit);
}
