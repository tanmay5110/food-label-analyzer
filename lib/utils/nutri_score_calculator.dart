class NutriScoreCalculator {
  /// Calculates the Nutri-Score grade (A-E) based on nutrition facts per 100g
  static String calculateGrade(Map<String, double> nutritionFacts) {
    // Step 1: Calculate negative points (0-40)
    final energyPoints = _calculateEnergyPoints(nutritionFacts);
    final sugarsPoints = _calculateSugarsPoints(nutritionFacts);
    final satFatPoints = _calculateSaturatedFatPoints(nutritionFacts);
    final sodiumPoints = _calculateSodiumPoints(nutritionFacts);
    
    final negativePoints = energyPoints + sugarsPoints + satFatPoints + sodiumPoints;
    
    // Step 2: Calculate positive points (0-15)
    final fiberPoints = _calculateFiberPoints(nutritionFacts);
    final proteinPoints = _calculateProteinPoints(nutritionFacts);
    final fruitVegPoints = _calculateFruitVegPoints(nutritionFacts);
    
    final positivePoints = fiberPoints + proteinPoints + fruitVegPoints;
    
    // Step 3: Calculate final score
    int finalScore = negativePoints - positivePoints;
    
    // Step 4: Convert to grade
    if (finalScore <= -1) return 'A';
    if (finalScore <= 2) return 'B';
    if (finalScore <= 10) return 'C';
    if (finalScore <= 18) return 'D';
    return 'E';
  }
  
  /// Calculates the health score (1-10) based on Nutri-Score
  static int calculateScore(Map<String, double> nutritionFacts) {
    String grade = calculateGrade(nutritionFacts);
    
    switch (grade) {
      case 'A': return 10;
      case 'B': return 8;
      case 'C': return 6;
      case 'D': return 4;
      case 'E': return 2;
      default: return 5;
    }
  }
  
  /// Generates consumption advice based on the health grade, with specific frequency guidelines
  static String getConsumptionAdvice(String grade) {
    switch (grade) {
      case 'A':
        return 'This is an excellent food choice that can be consumed daily as part of a balanced diet. Suitable for regular consumption (4-7 times per week).';
      case 'B':
        return 'This is a good food choice that can be consumed several times a week (2-4 times per week). Fits well in a balanced diet.';
      case 'C':
        return 'This food has average nutritional quality and should be consumed in moderation. Limit to about 1-2 times per week and consider balancing with healthier options.';
      case 'D':
        return 'This food has below average nutritional quality. Consider consuming only occasionally (1-2 times per month) and in small portions. Pair with healthier foods when possible.';
      case 'E':
        return 'This food has poor nutritional quality. Best consumed rarely (less than once a month) and in small amounts. Try to find healthier alternatives for regular consumption.';
      default:
        return 'Consume this food as part of a varied and balanced diet, paying attention to portion sizes and frequency.';
    }
  }
  
  // Energy: 0-10 points
  static int _calculateEnergyPoints(Map<String, double> nutritionFacts) {
    // Get energy in kJ
    double energyKcal = nutritionFacts['energy'] ?? 
                       nutritionFacts['calories'] ?? 
                       0.0;
    
    // Convert to kJ if needed (assuming the value is in kcal)
    double energyKJ = energyKcal * 4.184;
    
    // Assign points
    if (energyKJ <= 335) return 0;
    if (energyKJ <= 670) return 1;
    if (energyKJ <= 1005) return 2;
    if (energyKJ <= 1340) return 3;
    if (energyKJ <= 1675) return 4;
    if (energyKJ <= 2010) return 5;
    if (energyKJ <= 2345) return 6;
    if (energyKJ <= 2680) return 7;
    if (energyKJ <= 3015) return 8;
    if (energyKJ <= 3350) return 9;
    return 10;
  }
  
  // Sugars: 0-10 points
  static int _calculateSugarsPoints(Map<String, double> nutritionFacts) {
    double sugars = nutritionFacts['sugars'] ?? 
                   nutritionFacts['total_sugars'] ?? 
                   0.0;
    
    if (sugars <= 4.5) return 0;
    if (sugars <= 9) return 1;
    if (sugars <= 13.5) return 2;
    if (sugars <= 18) return 3;
    if (sugars <= 22.5) return 4;
    if (sugars <= 27) return 5;
    if (sugars <= 31) return 6;
    if (sugars <= 36) return 7;
    if (sugars <= 40) return 8;
    if (sugars <= 45) return 9;
    return 10;
  }
  
  // Saturated Fat: 0-10 points
  static int _calculateSaturatedFatPoints(Map<String, double> nutritionFacts) {
    double satFat = nutritionFacts['saturated_fat'] ?? 
                   nutritionFacts['saturated_fatty_acids'] ?? 
                   0.0;
    
    if (satFat <= 1) return 0;
    if (satFat <= 2) return 1;
    if (satFat <= 3) return 2;
    if (satFat <= 4) return 3;
    if (satFat <= 5) return 4;
    if (satFat <= 6) return 5;
    if (satFat <= 7) return 6;
    if (satFat <= 8) return 7;
    if (satFat <= 9) return 8;
    if (satFat <= 10) return 9;
    return 10;
  }
  
  // Sodium: 0-10 points
  static int _calculateSodiumPoints(Map<String, double> nutritionFacts) {
    double sodium = nutritionFacts['sodium'] ?? 0.0;
    
    if (sodium <= 90) return 0;
    if (sodium <= 180) return 1;
    if (sodium <= 270) return 2;
    if (sodium <= 360) return 3;
    if (sodium <= 450) return 4;
    if (sodium <= 540) return 5;
    if (sodium <= 630) return 6;
    if (sodium <= 720) return 7;
    if (sodium <= 810) return 8;
    if (sodium <= 900) return 9;
    return 10;
  }
  
  // Fiber: 0-5 points
  static int _calculateFiberPoints(Map<String, double> nutritionFacts) {
    double fiber = nutritionFacts['fiber'] ?? 
                  nutritionFacts['dietary_fiber'] ?? 
                  0.0;
    
    if (fiber <= 0.9) return 0;
    if (fiber <= 1.9) return 1;
    if (fiber <= 2.8) return 2;
    if (fiber <= 3.7) return 3;
    if (fiber <= 4.7) return 4;
    return 5;
  }
  
  // Protein: 0-5 points
  static int _calculateProteinPoints(Map<String, double> nutritionFacts) {
    double protein = nutritionFacts['protein'] ?? 0.0;
    
    if (protein <= 1.6) return 0;
    if (protein <= 3.2) return 1;
    if (protein <= 4.8) return 2;
    if (protein <= 6.4) return 3;
    if (protein <= 8.0) return 4;
    return 5;
  }
  
  // Fruits, vegetables, nuts: 0-5 points (estimate based on ingredients)
  static int _calculateFruitVegPoints(Map<String, double> nutritionFacts) {
    // Since we don't have direct access to fruit/veg percentage, this is an estimation
    // In a real app, this would need to be improved with ingredient analysis
    
    // For now, assume 0 points as a conservative estimate
    return 0;
  }
} 