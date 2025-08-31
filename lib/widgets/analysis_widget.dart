import 'package:flutter/material.dart';
import '../models/food_analysis_result.dart';

class AnalysisWidget extends StatelessWidget {
  final FoodAnalysisResult result;
  
  const AnalysisWidget({Key? key, required this.result}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Never check result.analysis - always show our generated content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutritional Quality',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'This product has a ${_getQualityText(result.healthGrade)} nutritional profile. ' +
          'It received a grade of ${result.healthGrade} with a score of ${result.healthScore}/10.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Consumption Recommendation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          result.consumptionAdvice,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  String _getQualityText(String grade) {
    switch (grade) {
      case 'A': return 'excellent';
      case 'B': return 'good';
      case 'C': return 'average';
      case 'D': return 'below average';
      case 'E': return 'poor';
      default: return 'moderate';
    }
  }
} 