import 'package:flutter/material.dart';
import '../components/app_header.dart';
import '../components/bottom_navigation.dart';
import '../components/food_item_card.dart';
import '../models/food_item.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class NutritionInfo {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class EatHealthyPage extends StatefulWidget {
  const EatHealthyPage({Key? key}) : super(key: key);

  @override
  State<EatHealthyPage> createState() => _EatHealthyPageState();
}

class _EatHealthyPageState extends State<EatHealthyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0;
  bool _showNutritionInsights = false;
  int _dailyCalorieGoal = 2000;

  final List<String> _filters = [
    'All',
    'Vegan',
    'Low Calorie',
    'High Protein',
    'Gluten Free',
    'Keto',
  ];

  // Sample nutrition information for each healthy food item
  final Map<String, NutritionInfo> _nutritionMap = {
    '6': NutritionInfo(
        calories: 320, protein: 12, carbs: 20, fat: 22), // Greek Salad
    '7': NutritionInfo(
        calories: 280, protein: 10, carbs: 28, fat: 14), // Avocado Toast
    '8': NutritionInfo(
        calories: 420, protein: 16, carbs: 64, fat: 9), // Quinoa Bowl
    '9': NutritionInfo(
        calories: 310, protein: 8, carbs: 52, fat: 7), // Smoothie Bowl
    '10': NutritionInfo(
        calories: 180, protein: 5, carbs: 18, fat: 8), // Kale & Spinach Soup
  };

  final List<String> _dietTypes = [
    'All',
    'Keto',
    'Vegan',
    'Low-Carb',
    'High-Protein',
    'Gluten-Free',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);

    // Calculate nutrition totals from cart items
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (var cartItem in cartModel.items) {
      final foodId = cartItem.item.id;
      if (_nutritionMap.containsKey(foodId)) {
        final nutrition = _nutritionMap[foodId]!;
        totalCalories += nutrition.calories * cartItem.quantity;
        totalProtein += nutrition.protein * cartItem.quantity;
        totalCarbs += nutrition.carbs * cartItem.quantity;
        totalFat += nutrition.fat * cartItem.quantity;
      }
    }

    // Calculate percentage of daily calorie goal
    double caloriePercentage = totalCalories / _dailyCalorieGoal;
    if (caloriePercentage > 1.0) caloriePercentage = 1.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Eat Healthy',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights, color: Colors.black),
            onPressed: () {
              setState(() {
                _showNutritionInsights = !_showNutritionInsights;
              });
            },
            tooltip: 'Nutrition Insights',
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Nutrition Insights Panel (collapsible)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showNutritionInsights ? 180 : 0,
            color: Colors.green.shade50,
            curve: Curves.easeInOut,
            child: _showNutritionInsights
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nutrition Insights',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Today\'s Goal: $_dailyCalorieGoal cal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Calorie progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Calories: $totalCalories / $_dailyCalorieGoal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(caloriePercentage * 100).toInt()}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: caloriePercentage > 0.9
                                        ? Colors.red
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: caloriePercentage,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  caloriePercentage > 0.9
                                      ? Colors.red
                                      : Colors.green.shade700,
                                ),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Macronutrient distribution
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNutrientIndicator(
                                'Protein', '$totalProtein g', Colors.purple),
                            _buildNutrientIndicator(
                                'Carbs', '$totalCarbs g', Colors.orange),
                            _buildNutrientIndicator(
                                'Fat', '$totalFat g', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured banner
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.green.shade50,
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Healthy Food Collection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Discover delicious meals with nutrition insights',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Diet type categories
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Text(
                      'Dietary Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _dietTypes.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryChip(
                          _dietTypes[index],
                          isSelected: _selectedFilterIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedFilterIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Healthy food items
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended Healthy Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          onPressed: () {
                            _showNutritionInfoDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: healthyFoodItems.length,
                      itemBuilder: (context, index) {
                        final item = healthyFoodItems[index];
                        final nutrition = _nutritionMap[item.id] ??
                            NutritionInfo(
                                calories: 0, protein: 0, carbs: 0, fat: 0);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FoodItemCard(
                              name: item.name,
                              imageUrl: item.imageUrl,
                              price: item.price,
                              restaurant: item.restaurant,
                              rating: item.rating,
                              timeEstimate: item.timeEstimate,
                              isVeg: true,
                              cuisine: item.cuisine,
                              isFeatured: index == 0,
                              distance: 2.5 + (index * 0.5),
                              foodItem: item,
                            ),
                            // Nutrition tag
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 20, left: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 16,
                                    color: Colors.green.shade800,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${nutrition.calories} Cal · ${nutrition.protein}g Protein',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSetCalorieGoalDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.fitness_center),
        tooltip: 'Set Nutrition Goals',
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildNutrientIndicator(String name, String value, Color color) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label,
      {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showNutritionInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text('Nutrition Information'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our nutrition insights feature helps you track your daily nutritional intake and make healthier choices.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '• Get real-time calorie tracking',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Monitor protein, carbs, and fat intake',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Set personal daily nutrition goals',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Make informed food choices',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSetCalorieGoalDialog(BuildContext context) {
    int tempGoal = _dailyCalorieGoal;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Calorie Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set your daily calorie goal to track your nutrition'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Daily Calories',
                suffixText: 'calories',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  tempGoal = int.tryParse(value) ?? _dailyCalorieGoal;
                }
              },
              controller:
                  TextEditingController(text: _dailyCalorieGoal.toString()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _dailyCalorieGoal = tempGoal;
                _showNutritionInsights = true;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
