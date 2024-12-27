import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lrm_app/models/search_model.dart';
import 'package:pocketbase/pocketbase.dart';

class SearchViewModel {
  final  pb = PocketBase(dotenv.env['POCKETBASE_URL']!);
  final StreamController<List<SearchItem>> _searchItemController = StreamController<List<SearchItem>>();
  Stream<List<SearchItem>> get searchItemsStream => _searchItemController.stream;
  List<SearchItem> allItems = [];

  Future<void> fetchItems() async {
    try {
      final shopRecords = await pb.collection('shop').getFullList();
      final menuRecords = await pb.collection('menu').getFullList();

      allItems = [
        ...shopRecords.map((shop) => SearchItem(
              id: shop.id,
              name: shop.data['shop_name'],
              image: shop.data['thunail_shop'],
              price: '',
              type: SearchItemType.shop,
            )),
        ...menuRecords.map((menu) => SearchItem(
              id: menu.id,
              name: menu.data['dish_name'],
              image: menu.data['thunail_menu'],
              price: menu.data['price'].toString(),
              type: SearchItemType.dish,
            )),
      ];

      _searchItemController.add(allItems);
    } catch (e) {
      print('Error fetching data: $e');
      _searchItemController.addError('Failed to fetch data');
    }
  }

  List<SearchItem> filterItems(String query) {
    return allItems.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void dispose() {
    _searchItemController.close();
  }
}