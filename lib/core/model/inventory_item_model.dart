import 'item_type_model.dart';
import 'user_model.dart';

enum InventoryDirection { inbound, outbound }

extension InventoryDirectionExtension on InventoryDirection {
  String get label => this == InventoryDirection.inbound ? 'In' : 'Out';
}

class InventoryItemModel {
  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.barcode,
    required this.itemType,
    required this.quantity,
    required this.timestamp,
    required this.handledBy,
    required this.direction,
    this.description = '',
  });

  final String id;
  final String name;
  final String brand;
  final String barcode;
  final ItemTypeModel itemType;
  final double quantity;
  final DateTime timestamp;
  final UserModel handledBy;
  final InventoryDirection direction;
  final String description;

  InventoryItemModel copyWith({
    String? name,
    String? brand,
    String? barcode,
    ItemTypeModel? itemType,
    double? quantity,
    DateTime? timestamp,
    UserModel? handledBy,
    InventoryDirection? direction,
    String? description,
  }) {
    return InventoryItemModel(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
      handledBy: handledBy ?? this.handledBy,
      direction: direction ?? this.direction,
      description: description ?? this.description,
    );
  }
}
