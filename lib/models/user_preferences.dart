import 'package:flutter/foundation.dart';

enum DietaryPreference {
  none,
  vegan,
  vegetarian,
  keto,
  paleo,
  glutenFree,
  dairyFree,
}

enum FitnessGoal {
  none,
  loseWeight,
  maintainWeight,
  gainMuscle,
  improveHealth,
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive,
}

class HealthMetrics {
  int weight; // in kg
  int height; // in cm
  int age;
  String gender;

  HealthMetrics({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
  });
}

class UserPreferences extends ChangeNotifier {
  DietaryPreference _dietaryPreference = DietaryPreference.none;
  FitnessGoal _fitnessGoal = FitnessGoal.none;
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  List<String> _allergies = [];
  List<String> _dislikedFoods = [];
  List<String> _favoriteCuisines = ['Italian', 'Indian', 'Japanese'];
  HealthMetrics? _healthMetrics;
  int _dailyCalorieGoal = 2000;
  bool _setupCompleted = false;

  // Getters
  DietaryPreference get dietaryPreference => _dietaryPreference;
  FitnessGoal get fitnessGoal => _fitnessGoal;
  ActivityLevel get activityLevel => _activityLevel;
  List<String> get allergies => _allergies;
  List<String> get dislikedFoods => _dislikedFoods;
  List<String> get favoriteCuisines => _favoriteCuisines;
  HealthMetrics? get healthMetrics => _healthMetrics;
  int get dailyCalorieGoal => _dailyCalorieGoal;
  bool get setupCompleted => _setupCompleted;

  // Setters
  set dietaryPreference(DietaryPreference preference) {
    _dietaryPreference = preference;
    notifyListeners();
  }

  set fitnessGoal(FitnessGoal goal) {
    _fitnessGoal = goal;
    notifyListeners();
  }

  set activityLevel(ActivityLevel level) {
    _activityLevel = level;
    notifyListeners();
  }

  set allergies(List<String> allergies) {
    _allergies = allergies;
    notifyListeners();
  }

  set dislikedFoods(List<String> dislikedFoods) {
    _dislikedFoods = dislikedFoods;
    notifyListeners();
  }

  set favoriteCuisines(List<String> cuisines) {
    _favoriteCuisines = cuisines;
    notifyListeners();
  }

  set healthMetrics(HealthMetrics? metrics) {
    _healthMetrics = metrics;
    // Recalculate daily calorie goal if health metrics are provided
    if (_healthMetrics != null) {
      calculateDailyCalorieGoal();
    }
    notifyListeners();
  }

  set dailyCalorieGoal(int goal) {
    _dailyCalorieGoal = goal;
    notifyListeners();
  }

  set setupCompleted(bool completed) {
    _setupCompleted = completed;
    notifyListeners();
  }

  // Add a single allergy
  void addAllergy(String allergy) {
    if (!_allergies.contains(allergy)) {
      _allergies.add(allergy);
      notifyListeners();
    }
  }

  // Remove a single allergy
  void removeAllergy(String allergy) {
    if (_allergies.contains(allergy)) {
      _allergies.remove(allergy);
      notifyListeners();
    }
  }

  // Add a disliked food
  void addDislikedFood(String food) {
    if (!_dislikedFoods.contains(food)) {
      _dislikedFoods.add(food);
      notifyListeners();
    }
  }

  // Remove a disliked food
  void removeDislikedFood(String food) {
    if (_dislikedFoods.contains(food)) {
      _dislikedFoods.remove(food);
      notifyListeners();
    }
  }

  // Add a favorite cuisine
  void addFavoriteCuisine(String cuisine) {
    if (!_favoriteCuisines.contains(cuisine)) {
      _favoriteCuisines.add(cuisine);
      notifyListeners();
    }
  }

  // Remove a favorite cuisine
  void removeFavoriteCuisine(String cuisine) {
    if (_favoriteCuisines.contains(cuisine)) {
      _favoriteCuisines.remove(cuisine);
      notifyListeners();
    }
  }

  // Calculate caloric needs based on Harris-Benedict equation
  void calculateDailyCalorieGoal() {
    if (_healthMetrics == null) return;

    double bmr = 0;
    if (_healthMetrics!.gender.toLowerCase() == 'male') {
      // BMR for men = 88.362 + (13.397 × weight in kg) + (4.799 × height in cm) - (5.677 × age in years)
      bmr = 88.362 +
          (13.397 * _healthMetrics!.weight) +
          (4.799 * _healthMetrics!.height) -
          (5.677 * _healthMetrics!.age);
    } else {
      // BMR for women = 447.593 + (9.247 × weight in kg) + (3.098 × height in cm) - (4.330 × age in years)
      bmr = 447.593 +
          (9.247 * _healthMetrics!.weight) +
          (3.098 * _healthMetrics!.height) -
          (4.330 * _healthMetrics!.age);
    }

    // Adjust BMR based on activity level
    double activityMultiplier = 1.2; // Sedentary by default
    switch (_activityLevel) {
      case ActivityLevel.sedentary:
        activityMultiplier = 1.2;
        break;
      case ActivityLevel.lightlyActive:
        activityMultiplier = 1.375;
        break;
      case ActivityLevel.moderatelyActive:
        activityMultiplier = 1.55;
        break;
      case ActivityLevel.veryActive:
        activityMultiplier = 1.725;
        break;
      case ActivityLevel.extremelyActive:
        activityMultiplier = 1.9;
        break;
    }

    double tdee = bmr * activityMultiplier; // Total Daily Energy Expenditure

    // Adjust based on fitness goal
    switch (_fitnessGoal) {
      case FitnessGoal.loseWeight:
        tdee -= 500; // Caloric deficit for weight loss
        break;
      case FitnessGoal.gainMuscle:
        tdee += 300; // Caloric surplus for muscle gain
        break;
      case FitnessGoal.maintainWeight:
      case FitnessGoal.improveHealth:
      case FitnessGoal.none:
        break; // No adjustment
    }

    _dailyCalorieGoal = tdee.round();
    notifyListeners();
  }

  // Method to check if a food item is compatible with user preferences
  bool isFoodCompatible(
      String foodName, String cuisine, List<String> ingredients) {
    // Check for allergies
    for (var allergy in _allergies) {
      if (ingredients.any((ingredient) =>
          ingredient.toLowerCase().contains(allergy.toLowerCase()))) {
        return false;
      }
    }

    // Check for disliked foods
    for (var disliked in _dislikedFoods) {
      if (foodName.toLowerCase().contains(disliked.toLowerCase())) {
        return false;
      }
    }

    // Check dietary preferences
    switch (_dietaryPreference) {
      case DietaryPreference.vegan:
        if (ingredients.any((ingredient) => [
              'meat',
              'chicken',
              'fish',
              'egg',
              'milk',
              'cheese',
              'butter',
              'cream',
              'honey'
            ].any((item) =>
                ingredient.toLowerCase().contains(item.toLowerCase())))) {
          return false;
        }
        break;
      case DietaryPreference.vegetarian:
        if (ingredients.any((ingredient) => [
              'meat',
              'chicken',
              'fish',
              'seafood'
            ].any((item) =>
                ingredient.toLowerCase().contains(item.toLowerCase())))) {
          return false;
        }
        break;
      case DietaryPreference.glutenFree:
        if (ingredients.any((ingredient) => ['wheat', 'barley', 'rye', 'gluten']
            .any((item) =>
                ingredient.toLowerCase().contains(item.toLowerCase())))) {
          return false;
        }
        break;
      case DietaryPreference.dairyFree:
        if (ingredients.any((ingredient) => [
              'milk',
              'cheese',
              'butter',
              'cream',
              'yogurt'
            ].any((item) =>
                ingredient.toLowerCase().contains(item.toLowerCase())))) {
          return false;
        }
        break;
      case DietaryPreference.keto:
        if (ingredients.any((ingredient) => [
              'sugar',
              'flour',
              'rice',
              'potato',
              'corn'
            ].any((item) =>
                ingredient.toLowerCase().contains(item.toLowerCase())))) {
          return false;
        }
        break;
      case DietaryPreference.paleo:
        if (ingredients.any((ingredient) => [
              'grain',
              'legume',
              'dairy',
              'processed'
            ].any((item) =>
                ingredient.toLowerCase().contains(item.toLowerCase())))) {
          return false;
        }
        break;
      case DietaryPreference.none:
        break; // No restrictions
    }

    return true;
  }

  // Method to get a personalized score for a food item (0-100)
  int getPersonalizedScore(String foodName, String cuisine,
      List<String> ingredients, int calories, int protein) {
    // Base score is 50
    int score = 50;

    // Check if cuisine is a favorite
    if (_favoriteCuisines.any((favCuisine) =>
        cuisine.toLowerCase().contains(favCuisine.toLowerCase()))) {
      score += 15;
    }

    // Adjust score based on fitness goal and macros
    switch (_fitnessGoal) {
      case FitnessGoal.loseWeight:
        // Prefer lower calorie foods
        if (calories < 300)
          score += 15;
        else if (calories > 600) score -= 15;
        break;
      case FitnessGoal.gainMuscle:
        // Prefer high protein foods
        if (protein > 25) score += 20;
        break;
      case FitnessGoal.improveHealth:
        // Prefer balanced foods
        if (calories < 500 && protein > 15) score += 15;
        break;
      case FitnessGoal.maintainWeight:
      case FitnessGoal.none:
        break; // No adjustment
    }

    // Clamp the score between 0 and 100
    if (score < 0) score = 0;
    if (score > 100) score = 100;

    return score;
  }
}
