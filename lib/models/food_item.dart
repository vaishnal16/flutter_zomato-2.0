import 'package:flutter/material.dart';

class FoodItem {
  final String id;
  final String name;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String imageUrl;
  final List<String> tags;
  final bool isVegetarian;
  final bool isDairyFree;
  final bool isGlutenFree;
  final double price;
  final String restaurant;
  final double rating;
  final String timeEstimate;
  final String cuisine;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.imageUrl,
    required this.tags,
    required this.isVegetarian,
    required this.isDairyFree,
    required this.isGlutenFree,
    this.price = 0.0,
    this.restaurant = '',
    this.rating = 0.0,
    this.timeEstimate = '',
    this.cuisine = '',
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags']),
      isVegetarian: json['isVegetarian'],
      isDairyFree: json['isDairyFree'],
      isGlutenFree: json['isGlutenFree'],
      price: json['price']?.toDouble() ?? 0.0,
      restaurant: json['restaurant'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      timeEstimate: json['timeEstimate'] ?? '',
      cuisine: json['cuisine'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'imageUrl': imageUrl,
      'tags': tags,
      'isVegetarian': isVegetarian,
      'isDairyFree': isDairyFree,
      'isGlutenFree': isGlutenFree,
      'price': price,
      'restaurant': restaurant,
      'rating': rating,
      'timeEstimate': timeEstimate,
      'cuisine': cuisine,
    };
  }
}

// Dummy data for food items
List<FoodItem> dummyFoodItems = [
  FoodItem(
    id: '1',
    name: 'Veg Biryani',
    imageUrl:
        'https://images.unsplash.com/photo-1633945274405-b6c8069046eb?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
    calories: 249,
    protein: 10.5,
    carbs: 30.5,
    fat: 5.5,
    description: 'A delicious vegetarian biryani',
    tags: ['Biryani', 'North Indian'],
    isVegetarian: true,
    isDairyFree: true,
    isGlutenFree: true,
    price: 199.0,
    restaurant: 'Biryani House',
    rating: 4.3,
    timeEstimate: '25-30 min',
    cuisine: 'North Indian',
  ),
  FoodItem(
    id: '2',
    name: 'Paneer Butter Masala',
    imageUrl:
        'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
    calories: 299,
    protein: 12.5,
    carbs: 25.5,
    fat: 10.5,
    description: 'A creamy paneer dish',
    tags: ['North Indian', 'Punjabi'],
    isVegetarian: true,
    isDairyFree: false,
    isGlutenFree: true,
    price: 249.0,
    restaurant: 'Punjabi Tadka',
    rating: 4.5,
    timeEstimate: '20-25 min',
    cuisine: 'North Indian',
  ),
  FoodItem(
    id: '3',
    name: 'Masala Dosa',
    imageUrl:
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
    calories: 149,
    protein: 5.5,
    carbs: 15.5,
    fat: 5.5,
    description: 'A crispy dosa with a spicy potato filling',
    tags: ['South Indian'],
    isVegetarian: true,
    isDairyFree: true,
    isGlutenFree: true,
    price: 129.0,
    restaurant: 'South Indian Delight',
    rating: 4.2,
    timeEstimate: '15-20 min',
    cuisine: 'South Indian',
  ),
  FoodItem(
    id: '4',
    name: 'Chicken Tikka',
    imageUrl:
        'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
    calories: 349,
    protein: 20.5,
    carbs: 15.5,
    fat: 10.5,
    description: 'A popular North Indian dish',
    tags: ['North Indian', 'Punjabi'],
    isVegetarian: false,
    isDairyFree: false,
    isGlutenFree: false,
    price: 299.0,
    restaurant: 'Punjabi Tadka',
    rating: 4.7,
    timeEstimate: '30-35 min',
    cuisine: 'North Indian',
  ),
  FoodItem(
    id: '5',
    name: 'Butter Naan',
    imageUrl:
        'https://images.unsplash.com/photo-1565557623262-b51c2513a641?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1071&q=80',
    calories: 49,
    protein: 1.5,
    carbs: 7.5,
    fat: 1.5,
    description: 'A soft and buttery naan bread',
    tags: ['North Indian'],
    isVegetarian: true,
    isDairyFree: false,
    isGlutenFree: false,
    price: 49.0,
    restaurant: 'Punjabi Tadka',
    rating: 4.0,
    timeEstimate: '10-15 min',
    cuisine: 'North Indian',
  ),
];

// Healthy food items
List<FoodItem> healthyFoodItems = [
  FoodItem(
    id: '6',
    name: 'Greek Salad',
    imageUrl:
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1168&q=80',
    calories: 249,
    protein: 2.5,
    carbs: 15.5,
    fat: 10.5,
    description: 'A refreshing Greek salad',
    tags: ['Salads', 'Healthy'],
    isVegetarian: true,
    isDairyFree: true,
    isGlutenFree: true,
    price: 179.0,
    restaurant: 'Healthy Bites',
    rating: 4.4,
    timeEstimate: '15-20 min',
    cuisine: 'Mediterranean',
  ),
  FoodItem(
    id: '7',
    name: 'Avocado Toast',
    imageUrl:
        'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80',
    calories: 199,
    protein: 3.5,
    carbs: 10.5,
    fat: 15.5,
    description: 'A healthy avocado toast',
    tags: ['Breakfast', 'Healthy'],
    isVegetarian: true,
    isDairyFree: true,
    isGlutenFree: true,
    price: 149.0,
    restaurant: 'Fresh & Fit',
    rating: 4.6,
    timeEstimate: '10-15 min',
    cuisine: 'Continental',
  ),
  FoodItem(
    id: '8',
    name: 'Quinoa Bowl',
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80',
    calories: 279,
    protein: 5.5,
    carbs: 20.5,
    fat: 5.5,
    description: 'A nutritious quinoa bowl',
    tags: ['Healthy', 'Bowls'],
    isVegetarian: true,
    isDairyFree: true,
    isGlutenFree: true,
    price: 229.0,
    restaurant: 'Healthy Bites',
    rating: 4.3,
    timeEstimate: '20-25 min',
    cuisine: 'Continental',
  ),
  FoodItem(
    id: '9',
    name: 'Smoothie Bowl',
    imageUrl:
        'https://images.unsplash.com/photo-1526424382096-74a93e105682?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
    calories: 229,
    protein: 2.5,
    carbs: 20.5,
    fat: 5.5,
    description: 'A delicious smoothie bowl',
    tags: ['Beverages', 'Healthy'],
    isVegetarian: true,
    isDairyFree: true,
    isGlutenFree: true,
    price: 189.0,
    restaurant: 'Fresh & Fit',
    rating: 4.5,
    timeEstimate: '10-15 min',
    cuisine: 'Continental',
  ),
  FoodItem(
    id: '10',
    name: 'Kale & Spinach Soup',
    imageUrl:
        'https://images.unsplash.com/photo-1547592166-23ac45744acd?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1171&q=80',
    calories: 179,
    protein: 3.5,
    carbs: 10.5,
    fat: 5.5,
    description: 'A healthy kale and spinach soup',
    tags: ['Soups', 'Healthy'],
    isVegetarian: true,
    isDairyFree: true,
    isGlutenFree: true,
    price: 159.0,
    restaurant: 'Healthy Bites',
    rating: 4.2,
    timeEstimate: '15-20 min',
    cuisine: 'Continental',
  ),
];
