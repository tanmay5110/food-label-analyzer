import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

// API constants
const String apiKey = "AIzaSyDXsGCQAM-qtz5xx-QM_iO9u1YMlA8vYwE";
const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';

// Color utility functions
Color getHealthColor(int score) {
  if (score >= 8) return Colors.blue.shade700;   // A - Excellent
  if (score >= 6) return Colors.blue.shade400;   // B - Good
  if (score >= 4) return Colors.amber.shade700;  // C - Average
  if (score >= 2) return Colors.orange.shade700; // D - Below average
  return Colors.red.shade700;                    // E - Poor
}

// Get color based on Singapore-style grade
Color getHealthColorFromGrade(String grade) {
  switch (grade) {
    case 'A':
      return Colors.blue.shade700;    // Excellent
    case 'B':
      return Colors.blue.shade400;    // Good
    case 'C':
      return Colors.amber.shade700;   // Average
    case 'D':
      return Colors.red.shade700;     // Below average
    default:
      return Colors.grey.shade700;    // Unknown
  }
}

// Grade descriptions
String getGradeDescription(String grade) {
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

// Consumption frequency advice by grade
String getConsumptionAdvice(String grade) {
  switch (grade) {
    case 'A':
      return 'Can be consumed regularly (4-7 times per week)';
    case 'B':
      return 'Can be consumed moderately (2-4 times per week)';
    case 'C':
      return 'Should be consumed occasionally (1-2 times per week)';
    case 'D':
      return 'Should be consumed rarely (once per month or less)';
    default:
      return 'Consume as part of a balanced diet';
  }
}

// Ultra-simplified prompt - focus only on ingredients and harmful ingredients
String getFoodLabelPrompt() {
  return """
  You are a food label analyzer. Determine if the image contains a food nutrition label.

  If the image does NOT contain a proper food nutrition label, respond with:
  {
    "isValidFoodLabel": false,
    "message": "This doesn't appear to be a food nutrition label. Please upload an image of a food label."
  }

  If it IS a valid food label, extract ONLY:
  1. Product name if visible
  2. Complete ingredients list exactly as shown
  3. Identify any potentially harmful ingredients for health

  For each harmful ingredient, provide:
  - The exact ingredient name as listed on the label
  - The concern (e.g., "Artificial additive", "Allergen", "Preservative")
  - Brief explanation of potential health effects
  - Severity level (low, medium, high)

  Return your response in JSON format:
  {
    "isValidFoodLabel": true,
    "productName": "Product name if visible",
    "ingredients": "Complete ingredients list as shown on label",
    "unsafeIngredients": [
      {
        "name": "Ingredient name",
        "concern": "Type of concern",
        "explanation": "Brief explanation of health effects",
        "severity": "low/medium/high"
      }
    ]
  }
  
  If no harmful ingredients are found, include an empty array for unsafeIngredients.
  Return only the JSON, nothing else.
  """;
}

// Keep simplified test prompt
String getSimplifiedPrompt() {
  return """
  Analyze this food label and return:
  {
    "isValidFoodLabel": true,
    "productName": "Test Product",
    "ingredients": "Water, Sugar, Salt, Artificial Flavor",
    "unsafeIngredients": [
      {
        "name": "Artificial Flavor",
        "concern": "Synthetic Additive",
        "explanation": "May cause allergic reactions in sensitive individuals",
        "severity": "low"
      }
    ]
  }
  """;
}

// Image compression function
Future<Uint8List> compressImage(Uint8List imageBytes) async {
  final codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: 800, // Reasonable size for text recognition
  );
  final frameInfo = await codec.getNextFrame();
  final data = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
  
  if (data == null) {
    // If compression fails, return original
    return imageBytes;
  }
  
  return data.buffer.asUint8List();
} 















































































































































































































