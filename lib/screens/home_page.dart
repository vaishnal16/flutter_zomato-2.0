import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/app_header.dart';
import '../components/bottom_navigation.dart';
import '../components/food_item_card.dart';
import '../models/food_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Use more reliable image URLs
  final List<Map<String, String>> _categoryImages = const [
    {
      'image':
          'https://b.zmtcdn.com/data/o2_assets/d0bd7c9405ac87f6aa65e31fe55800941632716575.png',
      'name': 'Pizza',
    },
    {
      'image':
          'https://b.zmtcdn.com/data/dish_images/d19a31d42d5913ff129cafd7cec772f81639737697.png',
      'name': 'Biryani',
    },
    {
      'image':
          'https://b.zmtcdn.com/data/dish_images/c2f22c42f7ba90d81440a88449f4e5891634806087.png',
      'name': 'Rolls',
    },
    {
      'image':
          'https://b.zmtcdn.com/data/dish_images/ccb7dc2ba2b054419f805da7f05704471634886169.png',
      'name': 'Burger',
    },
    {
      'image':
          'https://b.zmtcdn.com/data/dish_images/197987b7ebcd1ee08f8c25ea4e77e20f1634731334.png',
      'name': 'Thali',
    },
    {
      'image':
          'https://b.zmtcdn.com/data/dish_images/1437bc204cb5c892cb22d78b4347f4651634827140.png',
      'name': 'Chaat',
    },
  ];

  // Reliable offer images
  final List<Map<String, String>> _offerImages = const [
    {
      'image':
          'https://b.zmtcdn.com/data/pictures/chains/1/18140111/7a8e12310532da12f613c7730f99da6f.jpg',
      'offer': 'Get 50% off on your first order',
    },
    {
      'image':
          'https://b.zmtcdn.com/data/pictures/chains/3/143/4c2fdcaf8b30c6e771a3468eff9732c3.jpg',
      'offer': 'Free delivery on orders above ₹299',
    },
    {
      'image':
          'https://b.zmtcdn.com/data/pictures/3/18617413/c559a0c1b6654491465ad61c864ae8f4.jpg',
      'offer': 'Use code WELCOME20 for 20% off',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // App Header with search bar
          const AppHeader(),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick filters
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterChip('Sort', Icons.sort, context),
                          _buildFilterChip(
                              'Fast Delivery', Icons.timer, context),
                          _buildFilterChip('Rating 4.0+', Icons.star, context),
                          _buildFilterChip('Pure Veg', Icons.grass, context),
                          _buildFilterChip(
                              'Offers', Icons.local_offer, context),
                          _buildFilterChip(
                              'Takeaway', Icons.shopping_bag, context),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Food categories
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 8),
                    child: Text(
                      'Eat what makes you happy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categoryImages.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryItem(
                          context,
                          _categoryImages[index]['image']!,
                          _categoryImages[index]['name']!,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Offers section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offers For You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exclusive offers & discounts',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              _offerImages.length,
                              (index) => _buildOfferCard(
                                _offerImages[index]['image']!,
                                _offerImages[index]['offer']!,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Restaurants Near You section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Restaurants Near You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),

                  // Restaurant cards (updated from food items)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dummyFoodItems.length,
                      itemBuilder: (context, index) {
                        final foodItem = dummyFoodItems[index];
                        // Make first item featured and alternate veg status
                        return FoodItemCard(
                          name: foodItem.name,
                          imageUrl: foodItem.imageUrl,
                          price: foodItem.price,
                          restaurant: foodItem.restaurant,
                          rating: foodItem.rating,
                          timeEstimate: foodItem.timeEstimate,
                          isVeg: index % 2 == 0,
                          cuisine: foodItem.cuisine,
                          isFeatured: index == 0,
                          distance: 2.5 + (index * 0.5),
                          foodItem: foodItem, // Pass food item
                          onTap: () => context.go('/cart'),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, String imageUrl, String name) {
    return InkWell(
      onTap: () {
        // Navigate to search with the category name as query
        final uri = Uri(
          path: '/search',
          queryParameters: {'q': name},
        ).toString();
        context.go(uri);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: _buildNetworkImage(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                  padding: const EdgeInsets.all(15.0),
                  categoryName: name,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to search with the filter as query
        final uri = Uri(
          path: '/search',
          queryParameters: {'q': label},
        ).toString();
        context.go(uri);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String imageUrl, String offer) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: _buildNetworkImage(
              imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            offer,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Improved network image widget with error handling and caching
  Widget _buildNetworkImage(
    String url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.contain,
    EdgeInsetsGeometry? padding,
    String? categoryName,
  }) {
    // Choose appropriate icon based on category name
    IconData iconData = Icons.image_not_supported;
    if (categoryName != null) {
      switch (categoryName.toLowerCase()) {
        case 'pizza':
          iconData = Icons.local_pizza;
          break;
        case 'burger':
          iconData = Icons.lunch_dining;
          break;
        case 'biryani':
        case 'thali':
          iconData = Icons.restaurant_menu;
          break;
        case 'rolls':
          iconData = Icons.fastfood;
          break;
        case 'chaat':
          iconData = Icons.dinner_dining;
          break;
        default:
          iconData = Icons.restaurant;
      }
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE23744),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade100,
        child: Center(
          child: Icon(
            iconData,
            color: Colors.grey.shade400,
            size: 24,
          ),
        ),
      ),
    );

    if (padding != null) {
      return Padding(
        padding: padding,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
