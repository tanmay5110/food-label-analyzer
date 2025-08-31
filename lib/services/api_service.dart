import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/food_analysis_result.dart';
import '../utils/constants.dart';
import '../utils/nutri_score_calculator.dart';
import 'dart:io';

class ApiService {
  final String apiKey;
  
  ApiService({required this.apiKey});
  
  Future<FoodAnalysisResult> analyzeFoodLabel(Uint8List imageBytes) async {
    try {
      // Check network connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return FoodAnalysisResult.error("No internet connection. Please check your network and try again.");
      }
      
      // Encode image to base64
      final base64Image = base64Encode(imageBytes);
      
      // Create a more focused, consistent prompt for better ingredient identification
      final prompt = '''
Analyze this food label image. You are a strict food safety expert.

TASK: Carefully examine if this is a food label with ingredients and nutrition facts. Extract detailed information.

Return this JSON format:
{
  "isValidFoodLabel": true/false,
  "productName": "Product name from the label",
  "ingredients": "Complete ingredients list as comma-separated string",
  "nutritionFacts": {
    "calories": "Value with units (e.g., 240 kcal)",
    "total_fat": "Value with units (e.g., 4.5g)",
    "protein": "Value with units (e.g., 11g)",
    ... other nutrition facts
  },
  "unsafeIngredients": [
    {
      "name": "Exact ingredient name as on label",
      "concern": "Type of concern (e.g., Artificial additive, Preservative, etc.)",
      "severity": "low", "medium", or "high",
      "explanation": "Brief explanation of potential health effects"
    }
  ]
}

IMPORTANT RULES:
1. Always scrutinize ALL ingredients thoroughly
2. Flag ingredients like: artificial colors, flavors, sweeteners, preservatives, MSG, BHA/BHT, etc.
3. Be consistent - if an ingredient is potentially harmful, ALWAYS flag it
4. Use severity "high" for ingredients linked to serious health issues
5. Use severity "medium" for ingredients with moderate concerns
6. Use severity "low" for ingredients with mild or occasional concerns
7. If no harmful ingredients are found, return empty array for unsafeIngredients
8. If not a food label, return {"isValidFoodLabel": false}

Return ONLY the clean JSON object with no markdown formatting.
''';
      
      print("Starting API request to: $geminiApiUrl?key=$apiKey");
      
      // Prepare and send the request
      final response = await http.post(
        Uri.parse('$geminiApiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ]
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

      // Add detailed logging
      print("API Response Status: ${response.statusCode}");
      print("API Response Structure: (candidates, usageMetadata, modelVersion)");
      
      // Parse the JSON response from the API
      final rawResponse = json.decode(response.body);
      
      // Extract the text content from the Gemini response
      String responseText = rawResponse['candidates'][0]['content']['parts'][0]['text'];
      print('Raw Text Response: ${responseText.substring(0, min(100, responseText.length))}...');
      
      // Remove Markdown code block markers (```json)
      responseText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      print('Cleaned Text: ${responseText.substring(0, min(50, responseText.length))}...');
      
      // Now parse the actual content
      Map<String, dynamic> parsedResponse = json.decode(responseText);
      
      // Make sure isValidFoodLabel defaults to true if the field is missing
      bool isValid = parsedResponse['isValidFoodLabel'] != false;

      // Only continue processing if it's a valid food label
      if (!isValid) {
        return FoodAnalysisResult(
          productName: 'Not a Food Label',
          healthScore: 0,
          healthGrade: 'N/A',
          consumptionAdvice: 'This does not appear to be a food label.',
          isValidFoodLabel: false,
          nutritionFacts: {},
          nutritionFactsWithUnits: {},
          ingredients: [],
          criteriaResults: [],
          unsafeIngredients: [],
          errorMessage: 'The image does not appear to contain a food nutrition label.',
        );
      }
      
      // Parse nutrition facts with units
      Map<String, String> nutritionFactsWithUnits = {};
      Map<String, double> nutritionFactsValues = {};

      if (parsedResponse.containsKey('nutritionFacts') && 
          parsedResponse['nutritionFacts'] is Map) {
        final rawNutrition = parsedResponse['nutritionFacts'] as Map;
        
        rawNutrition.forEach((key, value) {
          String keyStr = key.toString();
          
          // Store the original value with units
          nutritionFactsWithUnits[keyStr] = value.toString();
          
          // Also extract numeric value for calculations
          if (value is num) {
            nutritionFactsValues[keyStr] = value.toDouble();
          } else if (value is String) {
            // Extract numeric portion using regex
            final numericMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(value.toString());
            if (numericMatch != null) {
              nutritionFactsValues[keyStr] = double.parse(numericMatch.group(1)!);
            }
          }
        });
      }
      
      // Calculate health grade and score locally
      String healthGrade = NutriScoreCalculator.calculateGrade(nutritionFactsValues);
      int healthScore = NutriScoreCalculator.calculateScore(nutritionFactsValues);

      // Always generate consumption advice using our local method
      String consumptionAdvice = NutriScoreCalculator.getConsumptionAdvice(healthGrade);
      
      // Handle ingredients
      List<String> ingredients = [];
      if (parsedResponse['ingredients'] is String) {
        ingredients = parsedResponse['ingredients'].toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (parsedResponse['ingredients'] is List) {
        ingredients = List<String>.from(parsedResponse['ingredients']);
      }
      
      // FIX: Parse criteria results properly
      List<CriterionResult> criteriaResults = [];
      if (parsedResponse.containsKey('criteriaResults') && parsedResponse['criteriaResults'] is List) {
        criteriaResults = (parsedResponse['criteriaResults'] as List).map((item) {
          if (item is Map) {
            return CriterionResult(
              name: item['name']?.toString() ?? '',
              value: item['value']?.toString() ?? '',
              standard: item['standard']?.toString() ?? '',
              met: item['met'] == true,
              explanation: item['explanation']?.toString() ?? '',
            );
          }
          return CriterionResult(
            name: 'Unknown',
            value: '',
            standard: '',
            met: false,
            explanation: '',
          );
        }).toList();
      }
      
      // Generate criteria based on Nutri-Score standards if none provided by API
      if (criteriaResults.isEmpty) {
        print('No criteria found, creating defaults based on nutrition facts');
        
        // Key nutrient values (per 100g)
        final energy = nutritionFactsValues['energy'] ?? nutritionFactsValues['calories'] ?? 0.0;
        final sugars = nutritionFactsValues['sugars'] ?? 0.0;
        final saturatedFat = nutritionFactsValues['saturated_fat'] ?? 0.0;
        final sodium = nutritionFactsValues['sodium'] ?? 0.0;
        final fiber = nutritionFactsValues['fiber'] ?? nutritionFactsValues['dietary_fiber'] ?? 0.0;
        final protein = nutritionFactsValues['protein'] ?? 0.0;
        
        // Create balanced criteria - B grade is the benchmark for "good"
        criteriaResults = [
          CriterionResult(
            name: "Energy Density",
            value: "${energy.toStringAsFixed(1)} kcal/100g",
            standard: "Less than 400 kcal per 100g",
            met: energy < 400,
            explanation: "Lower energy density foods help with weight management.",
          ),
          CriterionResult(
            name: "Sugar Content",
            value: "${sugars.toStringAsFixed(1)}g per 100g",
            standard: "Less than 5g per 100g",
            met: sugars < 5,
            explanation: "Low sugar is better for overall health and prevents diabetes.",
          ),
          CriterionResult(
            name: "Saturated Fat",
            value: "${saturatedFat.toStringAsFixed(1)}g per 100g",
            standard: "Less than 1.5g per 100g",
            met: saturatedFat < 1.5,
            explanation: "Low saturated fat reduces risk of heart disease.",
          ),
          CriterionResult(
            name: "Sodium Level",
            value: "${sodium.toStringAsFixed(1)}mg per 100g",
            standard: "Less than 400mg per 100g",
            met: sodium < 400,
            explanation: "Low sodium helps maintain healthy blood pressure.",
          ),
          CriterionResult(
            name: "Fiber Content",
            value: "${fiber.toStringAsFixed(1)}g per 100g",
            standard: "More than 3g per 100g",
            met: fiber > 3,
            explanation: "Higher fiber content supports digestive health.",
          ),
          CriterionResult(
            name: "Protein Content",
            value: "${protein.toStringAsFixed(1)}g per 100g",
            standard: "More than this is the benchmakr is 8g per 100g",
            met: protein > 8,
            explanation: "Adequate protein is essential for muscle maintenance.",
          ),
        ];
      }
      
      // Parse unsafe ingredients
      List<UnsafeIngredient> unsafeIngredients = [];
      if (parsedResponse.containsKey('unsafeIngredients') && 
          parsedResponse['unsafeIngredients'] is List) {
        final unsafeList = parsedResponse['unsafeIngredients'] as List;
        unsafeIngredients = unsafeList.map((item) {
          if (item is Map) {
            return UnsafeIngredient(
              name: item['name']?.toString() ?? 'Unknown',
              reason: item['reason']?.toString() ?? '',
              severity: item['severity']?.toString()?.toLowerCase() ?? 'medium',
              concern: item['concern']?.toString() ?? '',
              explanation: item['explanation']?.toString() ?? '',
            );
          }
          return UnsafeIngredient(
            name: 'Unknown',
            reason: '',
            severity: 'medium',
            concern: '',
            explanation: '',
          );
        }).toList();
      }
      
      return FoodAnalysisResult(
        productName: parsedResponse['productName']?.toString() ?? 'Unknown Product',
        healthScore: healthScore,
        healthGrade: healthGrade,
        consumptionAdvice: consumptionAdvice,
        isValidFoodLabel: isValid,
        nutritionFacts: nutritionFactsValues,
        nutritionFactsWithUnits: nutritionFactsWithUnits,
        ingredients: ingredients,
        criteriaResults: criteriaResults,
        unsafeIngredients: unsafeIngredients,
        errorMessage: parsedResponse['errorMessage']?.toString(),
        analysis: '', // Empty string instead of null or API-provided value
      );
      
    } catch (e, stackTrace) {
      print('Error analyzing food label: $e');
      print('Stack trace: $stackTrace');
      
      return FoodAnalysisResult(
        productName: 'Error',
        healthScore: 0,
        healthGrade: 'N/A',
        consumptionAdvice: '',
        isValidFoodLabel: false,
        nutritionFacts: {},
        nutritionFactsWithUnits: {},
        ingredients: [],
        criteriaResults: [],
        unsafeIngredients: [],
        errorMessage: 'Failed to analyze food label: $e',
      );
    }
  }

  double _estimateFruitVegNutsPercentage(List<String> ingredients) {
    // Implement logic to estimate fruit/veg/nuts percentage from ingredients
    // This is a simplified example
    return 0.0; // Default to 0% if unable to determine
  }
} 