class UserPreference {
  String? preferredCuisine;
  bool? isVegetarian;
  String? fitnessGoal; // 'weight_loss', 'muscle_gain', 'maintenance'
  double? calorieTarget;
  List<String> allergies;
  bool avoidDairy;
  bool avoidGluten;
  bool lowCarb;
  bool highProtein;

  UserPreference({
    this.preferredCuisine,
    this.isVegetarian,
    this.fitnessGoal,
    this.calorieTarget,
    this.allergies = const [],
    this.avoidDairy = false,
    this.avoidGluten = false,
    this.lowCarb = false,
    this.highProtein = false,
  });

  factory UserPreference.empty() {
    return UserPreference(
      preferredCuisine: null,
      isVegetarian: false,
      fitnessGoal: 'maintenance',
      calorieTarget: 2000,
      allergies: [],
      avoidDairy: false,
      avoidGluten: false,
      lowCarb: false,
      highProtein: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredCuisine': preferredCuisine,
      'isVegetarian': isVegetarian,
      'fitnessGoal': fitnessGoal,
      'calorieTarget': calorieTarget,
      'allergies': allergies,
      'avoidDairy': avoidDairy,
      'avoidGluten': avoidGluten,
      'lowCarb': lowCarb,
      'highProtein': highProtein,
    };
  }

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      preferredCuisine: json['preferredCuisine'],
      isVegetarian: json['isVegetarian'],
      fitnessGoal: json['fitnessGoal'],
      calorieTarget: json['calorieTarget'],
      allergies: List<String>.from(json['allergies'] ?? []),
      avoidDairy: json['avoidDairy'] ?? false,
      avoidGluten: json['avoidGluten'] ?? false,
      lowCarb: json['lowCarb'] ?? false,
      highProtein: json['highProtein'] ?? false,
    );
  }

  UserPreference copyWith({
    String? preferredCuisine,
    bool? isVegetarian,
    String? fitnessGoal,
    double? calorieTarget,
    List<String>? allergies,
    bool? avoidDairy,
    bool? avoidGluten,
    bool? lowCarb,
    bool? highProtein,
  }) {
    return UserPreference(
      preferredCuisine: preferredCuisine ?? this.preferredCuisine,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      allergies: allergies ?? this.allergies,
      avoidDairy: avoidDairy ?? this.avoidDairy,
      avoidGluten: avoidGluten ?? this.avoidGluten,
      lowCarb: lowCarb ?? this.lowCarb,
      highProtein: highProtein ?? this.highProtein,
    );
  }
}
