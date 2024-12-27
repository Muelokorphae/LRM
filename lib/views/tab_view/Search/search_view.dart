
import 'package:flutter/material.dart';
import 'package:lrm_app/ViewModels/search_view_model.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/models/search_model.dart';
import 'package:lrm_app/views/shop/shop_detail_view.dart';
import 'package:lrm_app/views/tab_view/home/menu_detail_view.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final SearchViewModel _viewModel = SearchViewModel();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<SearchItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      filteredItems = _viewModel.filterItems(_searchController.text);
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await _viewModel.fetchItems();
    _viewModel.searchItemsStream.listen((items) {
      setState(() {
        _isLoading = false;
        filteredItems = items;
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 160, 116, 131),
      appBar: AppBar(title: const Text('Search'),
       backgroundColor: const Color.fromARGB(255, 209, 157, 175),
      ),
     
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                
              ),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: filteredItems.isEmpty
                        ? const Center(child: Text('No results found.'))
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final imageUrl = item.type == SearchItemType.shop
                                  ? '${_viewModel.pb.baseURL}/api/files/shop/${item.id}/${item.image}'
                                  : '${_viewModel.pb.baseURL}/api/files/menu/${item.id}/${item.image}';

                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  leading: Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.price.isNotEmpty ? item.price : 'Shop',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.priceColor,
                                    ),
                                  ),
                                  onTap: () {
                                    if (item.type == SearchItemType.shop) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ShopDetailView(shopId: item.id),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MenuDetailView(menuId: item.id),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
