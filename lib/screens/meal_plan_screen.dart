import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_preferences.dart';
import '../models/food_item.dart';
import '../models/cart_model.dart';
import '../components/food_item_card.dart';
import '../components/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _showSetupPrompt = true;
  List<FoodItem> _recommendedItems = [];
  bool _isGeneratingPlan = false;
  String _selectedDay = 'Today';
  String _selectedMeal = 'Lunch';

  final List<String> _days = [
    'Today',
    'Tomorrow',
    'Day 3',
    'Day 4',
    'Day 5',
    'Day 6',
    'Day 7'
  ];
  final List<String> _meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  // Ingredients for food items (to simulate real data for filtering)
  final Map<String, List<String>> _foodIngredients = {
    '6': [
      'cucumber',
      'tomato',
      'olive oil',
      'feta cheese',
      'olives',
      'onion'
    ], // Greek Salad
    '7': ['avocado', 'bread', 'egg', 'tomato', 'olive oil'], // Avocado Toast
    '8': [
      'quinoa',
      'chicken',
      'broccoli',
      'sweet potato',
      'olive oil'
    ], // Quinoa Bowl
    '9': ['banana', 'berries', 'yogurt', 'granola', 'honey'], // Smoothie Bowl
    '10': [
      'kale',
      'spinach',
      'vegetable broth',
      'garlic',
      'onion'
    ], // Kale & Spinach Soup
  };

  @override
  void initState() {
    super.initState();
    // Delay slightly to allow context to be available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateMealRecommendations();
    });
  }

  void _generateMealRecommendations() {
    setState(() {
      _isGeneratingPlan = true;
    });

    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    // Filter healthy food items based on user preferences
    _recommendedItems = healthyFoodItems.where((item) {
      // Get ingredients for this food
      final ingredients = _foodIngredients[item.id] ?? [];

      // Check if food is compatible with user preferences
      return userPrefs.isFoodCompatible(item.name, item.cuisine, ingredients);
    }).toList();

    // Sort items by personalized score
    _recommendedItems.sort((a, b) {
      final ingredientsA = _foodIngredients[a.id] ?? [];
      final ingredientsB = _foodIngredients[b.id] ?? [];

      final scoreA = userPrefs.getPersonalizedScore(
          a.name,
          a.cuisine,
          ingredientsA,
          _getNutritionValue(a.id, 'calories'),
          _getNutritionValue(a.id, 'protein'));

      final scoreB = userPrefs.getPersonalizedScore(
          b.name,
          b.cuisine,
          ingredientsB,
          _getNutritionValue(b.id, 'calories'),
          _getNutritionValue(b.id, 'protein'));

      return scoreB.compareTo(scoreA); // Descending order
    });

    // Simulate slight delay for loading
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isGeneratingPlan = false;
      });
    });
  }

  int _getNutritionValue(String foodId, String nutrient) {
    // Sample nutrition values (would be fetched from database in a real app)
    final nutritionMap = {
      '6': {
        'calories': 320,
        'protein': 12,
        'carbs': 20,
        'fat': 22
      }, // Greek Salad
      '7': {
        'calories': 280,
        'protein': 10,
        'carbs': 28,
        'fat': 14
      }, // Avocado Toast
      '8': {
        'calories': 420,
        'protein': 16,
        'carbs': 64,
        'fat': 9
      }, // Quinoa Bowl
      '9': {
        'calories': 310,
        'protein': 8,
        'carbs': 52,
        'fat': 7
      }, // Smoothie Bowl
      '10': {
        'calories': 180,
        'protein': 5,
        'carbs': 18,
        'fat': 8
      }, // Kale & Spinach Soup
    };

    return nutritionMap[foodId]?[nutrient] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context);
    final cartModel = Provider.of<CartModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Personalized Meal Plan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _generateMealRecommendations,
            tooltip: 'Refresh Recommendations',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              _showPreferencesDialog(context);
            },
            tooltip: 'Preferences',
          ),
        ],
      ),
      body: _showSetupPrompt && !userPrefs.setupCompleted
          ? _buildSetupPrompt(context)
          : Column(
              children: [
                // Meal plan selector
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your daily plan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              '${userPrefs.dailyCalorieGoal} calories',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Day selector
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _days.length,
                          itemBuilder: (context, index) {
                            final day = _days[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDay = day;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: _selectedDay == day
                                      ? Colors.green.shade700
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _selectedDay == day
                                        ? Colors.green.shade700
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedDay == day
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Meal type selector
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _meals.length,
                          itemBuilder: (context, index) {
                            final meal = _meals[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMeal = meal;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: _selectedMeal == meal
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _selectedMeal == meal
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  meal,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedMeal == meal
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Meal plan content
                Expanded(
                  child: _isGeneratingPlan
                      ? _buildLoadingState()
                      : _recommendedItems.isEmpty
                          ? _buildEmptyState()
                          : _buildRecommendations(),
                ),
              ],
            ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildSetupPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Personalized Meal Planning',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Set up your preferences to get a personalized meal plan tailored to your health goals and dietary needs.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _showSetupDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Setup Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showSetupPrompt = false;
                });
                _generateMealRecommendations();
              },
              child: const Text('Skip for Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 24),
          Text(
            'Generating your personalized meal plan...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_food,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No recommendations available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Try adjusting your dietary preferences or fitness goals',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _showPreferencesDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              child: const Text('Update Preferences'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recommended for $_selectedMeal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendedItems.length,
            itemBuilder: (context, index) {
              final item = _recommendedItems[index];
              final ingredients = _foodIngredients[item.id] ?? [];
              final calorie = _getNutritionValue(item.id, 'calories');
              final protein = _getNutritionValue(item.id, 'protein');
              final score = userPrefs.getPersonalizedScore(
                  item.name, item.cuisine, ingredients, calorie, protein);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
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
                      // Match score badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.thumb_up,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$score% Match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Nutrition info
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, left: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
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
                          '$calorie Cal · ${protein}g Protein',
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
      ],
    );
  }

  void _showSetupDialog(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    DietaryPreference selectedDiet = userPrefs.dietaryPreference;
    FitnessGoal selectedGoal = userPrefs.fitnessGoal;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Setup Your Preferences'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dietary Preference',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: DietaryPreference.values.map((diet) {
                      return ChoiceChip(
                        label: Text(_getDietaryLabel(diet)),
                        selected: selectedDiet == diet,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedDiet = diet;
                          });
                        },
                        selectedColor: Colors.green.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Fitness Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: FitnessGoal.values.map((goal) {
                      return ChoiceChip(
                        label: Text(_getFitnessGoalLabel(goal)),
                        selected: selectedGoal == goal,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedGoal = goal;
                          });
                        },
                        selectedColor: Colors.green.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'For more detailed preferences and calorie goals, use the Preferences button in the app bar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  userPrefs.dietaryPreference = selectedDiet;
                  userPrefs.fitnessGoal = selectedGoal;
                  userPrefs.setupCompleted = true;
                  setState(() {
                    _showSetupPrompt = false;
                  });
                  _generateMealRecommendations();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showPreferencesDialog(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    DietaryPreference selectedDiet = userPrefs.dietaryPreference;
    FitnessGoal selectedGoal = userPrefs.fitnessGoal;
    ActivityLevel selectedActivity = userPrefs.activityLevel;
    int dailyCalories = userPrefs.dailyCalorieGoal;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.settings, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 8),
                const Text('Meal Plan Preferences'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dietary Preference',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: DietaryPreference.values.map((diet) {
                      return ChoiceChip(
                        label: Text(_getDietaryLabel(diet)),
                        selected: selectedDiet == diet,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedDiet = diet;
                          });
                        },
                        selectedColor: Colors.green.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Fitness Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: FitnessGoal.values.map((goal) {
                      return ChoiceChip(
                        label: Text(_getFitnessGoalLabel(goal)),
                        selected: selectedGoal == goal,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedGoal = goal;
                          });
                        },
                        selectedColor: Colors.green.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Activity Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ActivityLevel.values.map((activity) {
                      return ChoiceChip(
                        label: Text(_getActivityLabel(activity)),
                        selected: selectedActivity == activity,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedActivity = activity;
                          });
                        },
                        selectedColor: Colors.green.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Daily Calorie Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter daily calorie goal',
                      suffixText: 'calories',
                    ),
                    controller:
                        TextEditingController(text: dailyCalories.toString()),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setDialogState(() {
                          dailyCalories = int.tryParse(value) ?? dailyCalories;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Advanced Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // This would navigate to a more detailed setup screen in a real app
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Advanced setup coming soon')),
                      );
                    },
                    child: const Text('Health Metrics & Allergies'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  userPrefs.dietaryPreference = selectedDiet;
                  userPrefs.fitnessGoal = selectedGoal;
                  userPrefs.activityLevel = selectedActivity;
                  userPrefs.dailyCalorieGoal = dailyCalories;
                  userPrefs.setupCompleted = true;
                  _generateMealRecommendations();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  String _getDietaryLabel(DietaryPreference preference) {
    switch (preference) {
      case DietaryPreference.none:
        return 'No Preference';
      case DietaryPreference.vegan:
        return 'Vegan';
      case DietaryPreference.vegetarian:
        return 'Vegetarian';
      case DietaryPreference.keto:
        return 'Keto';
      case DietaryPreference.paleo:
        return 'Paleo';
      case DietaryPreference.glutenFree:
        return 'Gluten-Free';
      case DietaryPreference.dairyFree:
        return 'Dairy-Free';
    }
  }

  String _getFitnessGoalLabel(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.none:
        return 'No Specific Goal';
      case FitnessGoal.loseWeight:
        return 'Lose Weight';
      case FitnessGoal.maintainWeight:
        return 'Maintain Weight';
      case FitnessGoal.gainMuscle:
        return 'Build Muscle';
      case FitnessGoal.improveHealth:
        return 'Improve Health';
    }
  }

  String _getActivityLabel(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extremelyActive:
        return 'Extremely Active';
    }
  }
}
