class FoodAnalysisResult {
  String productName;
  int healthScore;
  String healthGrade;
  String consumptionAdvice;
  bool isValidFoodLabel;
  Map<String, double> nutritionFacts;
  Map<String, String> nutritionFactsWithUnits;
  List<String> ingredients;
  List<CriterionResult> criteriaResults;
  List<UnsafeIngredient> unsafeIngredients;
  String? errorMessage;
  String analysis;
  Map<String, NutritionCriterion>? nutritionCriteria;
  
  FoodAnalysisResult({
    required this.productName,
    required this.healthScore,
    required this.healthGrade,
    required this.consumptionAdvice,
    required this.isValidFoodLabel,
    required this.nutritionFacts,
    required this.nutritionFactsWithUnits,
    required this.ingredients,
    required this.criteriaResults,
    required this.unsafeIngredients,
    this.errorMessage,
    this.analysis = '',
    this.nutritionCriteria,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    // Add debug logging
    print("Creating FoodAnalysisResult from: ${json.keys}");
    
    List<UnsafeIngredient>? unsafeList;
    if (json.containsKey('unsafeIngredients')) {
      try {
        final unsafeData = json['unsafeIngredients'];
        print("Unsafe ingredients data type: ${unsafeData.runtimeType}");
        
        if (unsafeData is List) {
          unsafeList = unsafeData
              .map((item) => UnsafeIngredient.fromJson(item))
              .toList();
          print("Parsed ${unsafeList.length} unsafe ingredients");
        } else {
          print("unsafeIngredients is not a List: $unsafeData");
        }
      } catch (e) {
        print("Error parsing unsafe ingredients: $e");
      }
    } else {
      print("No unsafeIngredients key in JSON");
    }
    
    final int score = int.tryParse(json['healthScore']?.toString() ?? '0') ?? 0;
    String? grade = json['healthGrade']?.toString();
    
    // Parse nutrition criteria
    Map<String, NutritionCriterion>? criteria;
    if (json.containsKey('nutritionCriteria') && json['nutritionCriteria'] is Map) {
      criteria = {};
      try {
        final criteriaData = json['nutritionCriteria'] as Map;
        criteriaData.forEach((key, value) {
          if (value is Map) {
            criteria![key.toString()] = NutritionCriterion.fromJson(Map<String, dynamic>.from(value));
          }
        });
      } catch (e) {
        print("Error parsing nutrition criteria: $e");
      }
    }
    
    return FoodAnalysisResult(
      productName: json['productName'] ?? '',
      healthGrade: grade ?? scoreToGrade(score),
      nutritionFacts: Map<String, double>.from(json['nutritionFacts'] ?? {}),
      nutritionFactsWithUnits: Map<String, String>.from(json['nutritionFactsWithUnits'] ?? {}),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      isValidFoodLabel: json['isValidFoodLabel'] ?? true,
      healthScore: score,
      criteriaResults: List<CriterionResult>.from(json['criteriaResults'] ?? []),
      unsafeIngredients: List<UnsafeIngredient>.from(json['unsafeIngredients'] ?? []),
      errorMessage: json['errorMessage']?.toString(),
      analysis: json['analysis']?.toString() ?? '',
      nutritionCriteria: json['nutritionCriteria'] != null
          ? (json['nutritionCriteria'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                NutritionCriterion(
                  name: value['name'] as String? ?? '',
                  value: value['value'] as String? ?? '',
                  standard: value['standard'] as String? ?? '',
                  met: value['met'] as bool? ?? false,
                  explanation: value['explanation'] as String? ?? '',
                ),
              ),
            )
          : null,
      consumptionAdvice: json['consumptionAdvice']?.toString() ?? '',
    );
  }

  factory FoodAnalysisResult.error(String message) {
    return FoodAnalysisResult(
      productName: 'Error',
      healthScore: 0,
      healthGrade: 'N/A',
      isValidFoodLabel: false,
      nutritionFacts: {},
      nutritionFactsWithUnits: {},
      ingredients: [],
      criteriaResults: [],
      unsafeIngredients: [],
      errorMessage: message,
      consumptionAdvice: '',
    );
  }
  
  // Convert a numerical score to Singapore-style grade
  static String scoreToGrade(int score) {
    if (score >= 9) return 'A';
    if (score >= 7) return 'B';
    if (score >= 5) return 'C';
    return 'D';
  }
  
  // Description for each grade
  static String getGradeDescription(String grade) {
    switch (grade) {
      case 'A':
        return 'Excellent nutritional quality';
      case 'B':
        return 'Good nutritional quality';
      case 'C':
        return 'Average nutritional quality';
      case 'D':
        return 'Below average nutritional quality';
      default:
        return 'Unknown';
    }
  }
  
  // Get criteria that meet the HCS standards
  List<String> getPositiveCriteria() {
    if (nutritionCriteria == null) return [];
    return nutritionCriteria!.entries
        .where((entry) => entry.value.meetsStandard)
        .map((entry) => entry.key)
        .toList();
  }
  
  // Get criteria that do not meet the HCS standards
  List<String> getNegativeCriteria() {
    if (nutritionCriteria == null) return [];
    return nutritionCriteria!.entries
        .where((entry) => !entry.value.meetsStandard)
        .map((entry) => entry.key)
        .toList();
  }

  // Helper methods for nutrition criteria
  List<MapEntry<String, NutritionCriterion>> getNutritionCriteriaEntries() {
    if (nutritionCriteria == null) return [];
    return nutritionCriteria!.entries.toList();
  }

  List<MapEntry<String, NutritionCriterion>> getMetCriteria() {
    if (nutritionCriteria == null) return [];
    return nutritionCriteria!.entries
        .where((entry) => entry.value.meetsStandard)
        .toList();
  }

  List<MapEntry<String, NutritionCriterion>> getUnmetCriteria() {
    if (nutritionCriteria == null) return [];
    return nutritionCriteria!.entries
        .where((entry) => !entry.value.meetsStandard)
        .toList();
  }

  // Helper method to check if result is valid
  bool get isValid => isValidFoodLabel && errorMessage == null;

  String get displayAnalysis {
    if (analysis == null || analysis.isEmpty) {
      return 'This product has a health grade of $healthGrade (score: $healthScore/10). ' +
             'Consider the nutritional facts when deciding consumption frequency.';
    }
    return analysis;
  }
}

class UnsafeIngredient {
  final String name;
  final String reason;
  final String severity;
  final String concern;
  final String explanation;

  UnsafeIngredient({
    required this.name,
    required this.reason,
    required this.severity,
    required this.concern,
    required this.explanation,
  });

  factory UnsafeIngredient.fromJson(Map<String, dynamic> json) {
    // Add debug log
    print("Creating UnsafeIngredient from: ${json.keys}");
    
    return UnsafeIngredient(
      name: json['name'] ?? '',
      reason: json['reason'] ?? '',
      severity: json['severity'] ?? '',
      concern: json['concern'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class NutritionCriterion {
  final String name;
  final String value;
  final String standard;
  final bool met;
  final String explanation;

  NutritionCriterion({
    required this.name,
    required this.value,
    required this.standard,
    required this.met,
    required this.explanation,
  });

  factory NutritionCriterion.fromJson(Map<String, dynamic> json) {
    return NutritionCriterion(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      standard: json['standard'] ?? '',
      met: json['met'] ?? false,
      explanation: json['explanation'] ?? '',
    );
  }

  bool get meetsStandard => met;
}

class CriterionResult {
  final String name;
  final String value;
  final String standard;
  final bool met;
  final String explanation;
  
  CriterionResult({
    required this.name,
    required this.value,
    required this.standard,
    required this.met,
    required this.explanation,
  });
} 