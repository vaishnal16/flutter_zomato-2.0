import 'package:zomato_fixed/models/food_item.dart';

class MealPlanDay {
  final String dayOfWeek;
  final List<FoodItem> breakfast;
  final List<FoodItem> lunch;
  final List<FoodItem> dinner;
  final List<FoodItem> snacks;

  MealPlanDay({
    required this.dayOfWeek,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  });

  factory MealPlanDay.fromJson(Map<String, dynamic> json) {
    return MealPlanDay(
      dayOfWeek: json['dayOfWeek'],
      breakfast: (json['breakfast'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
      lunch: (json['lunch'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
      dinner: (json['dinner'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
      snacks: (json['snacks'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'breakfast': breakfast.map((item) => item.toJson()).toList(),
      'lunch': lunch.map((item) => item.toJson()).toList(),
      'dinner': dinner.map((item) => item.toJson()).toList(),
      'snacks': snacks.map((item) => item.toJson()).toList(),
    };
  }
}

class MealPlan {
  final String id;
  final String name;
  final String fitnessGoal;
  final List<MealPlanDay> days;
  final double estimatedCalories;
  final DateTime createdAt;

  MealPlan({
    required this.id,
    required this.name,
    required this.fitnessGoal,
    required this.days,
    required this.estimatedCalories,
    required this.createdAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      name: json['name'],
      fitnessGoal: json['fitnessGoal'],
      days: (json['days'] as List)
          .map((day) => MealPlanDay.fromJson(day))
          .toList(),
      estimatedCalories: json['estimatedCalories'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fitnessGoal': fitnessGoal,
      'days': days.map((day) => day.toJson()).toList(),
      'estimatedCalories': estimatedCalories,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
