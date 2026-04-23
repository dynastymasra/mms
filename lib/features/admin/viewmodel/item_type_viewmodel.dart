import 'package:flutter/foundation.dart';
import '../../../core/data/item_type_repository.dart';
import '../../../core/model/item_type_model.dart';

class ItemTypeViewModel extends ChangeNotifier {
  final _repo = ItemTypeRepository();

  List<ItemTypeModel> _all = [];
  List<ItemTypeModel> _filtered = [];
  String _query = '';

  List<ItemTypeModel> get items => _filtered;

  ItemTypeViewModel() {
    _reload();
  }

  void _reload() {
    _all = _repo.all.toList();
    _applyFilter();
  }

  void _applyFilter() {
    final q = _query.toLowerCase();
    _filtered = q.isEmpty
        ? List.of(_all)
        : _all.where((t) => t.name.toLowerCase().contains(q)).toList();
    notifyListeners();
  }

  void search(String query) {
    _query = query.trim();
    _applyFilter();
  }

  void add({required String name, required ItemUnit unit}) {
    _repo.add(ItemTypeModel(id: _repo.generateId(), name: name.trim(), unit: unit));
    _reload();
  }

  void update(ItemTypeModel updated) {
    _repo.update(updated);
    _reload();
  }

  void remove(String id) {
    _repo.remove(id);
    _reload();
  }
}
