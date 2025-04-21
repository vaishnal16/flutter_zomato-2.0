import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/food_item_card.dart';
import '../models/food_item.dart';
import '../components/bottom_navigation.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;

  const SearchPage({Key? key, required this.initialQuery}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  List<FoodItem> _searchResults = [];
  bool _isLoading = false;

  // Common search categories
  final List<String> _searchSuggestions = [
    'Pizza',
    'Burger',
    'Biryani',
    'North Indian',
    'Chinese',
    'South Indian',
    'Italian',
    'Fast Food',
    'Healthy Food',
    'Desserts',
    'Ice Cream'
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final results = [...dummyFoodItems, ...healthyFoodItems].where((item) {
        final name = item.name.toLowerCase();
        final description = item.description.toLowerCase();
        final restaurant = item.restaurant.toLowerCase();
        final cuisine = item.cuisine.toLowerCase();
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) ||
            description.contains(searchLower) ||
            restaurant.contains(searchLower) ||
            cuisine.contains(searchLower) ||
            item.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE23744),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery.isEmpty,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for restaurant, cuisine or a dish',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                });
              },
            ),
          ),
          onChanged: (value) {
            if (value.length > 2) {
              _performSearch(value);
            } else if (value.isEmpty) {
              setState(() {
                _searchResults = [];
              });
            }
          },
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white),
            onPressed: () {
              // Voice search functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice search coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchController.text.isEmpty) ...[
            // Show search suggestions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Popular Cuisines',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchSuggestions
                  .map((suggestion) => InkWell(
                        onTap: () {
                          _searchController.text = suggestion;
                          _performSearch(suggestion);
                        },
                        child: Chip(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          label: Text(suggestion),
                          labelStyle: TextStyle(color: Colors.grey.shade800),
                        ),
                      ))
                  .toList(),
            ),
          ] else if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                  color: Color(0xFFE23744),
                ),
              ),
            ),
          ] else if (_searchResults.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results found for "${_searchController.text}"',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try different keywords or check for spelling mistakes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Show results count
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${_searchResults.length} results found for "${_searchController.text}"',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            // Show search results
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return FoodItemCard(
                    name: item.name,
                    imageUrl: item.imageUrl,
                    price: item.price,
                    restaurant: item.restaurant,
                    rating: item.rating,
                    timeEstimate: item.timeEstimate,
                    isVeg: item.isVegetarian,
                    cuisine: item.cuisine,
                    isFeatured: false,
                    distance: 2.5 + (index * 0.5),
                    foodItem: item,
                  );
                },
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }
}
