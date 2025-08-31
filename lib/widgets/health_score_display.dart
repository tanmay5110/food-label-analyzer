import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../utils/constants.dart';
import '../models/food_analysis_result.dart';

class HealthScoreDisplay extends StatelessWidget {
  final int score;
  final String grade;
  final String analysis;
  final Uint8List imageBytes;
  final int unsafeIngredientsCount;

  const HealthScoreDisplay({
    Key? key,
    required this.score,
    required this.grade,
    required this.analysis,
    required this.imageBytes,
    this.unsafeIngredientsCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthColor = getHealthColorFromGrade(grade);
    final gradeDescription = FoodAnalysisResult.getGradeDescription(grade);
    
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: healthColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image thumbnail
          Container(
            height: 100,
            width: 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Health grade display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Grade badge
              Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    grade,
                    style: TextStyle(
                      color: healthColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Grade description
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Grade',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      gradeDescription,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Warnings indicator (if any unsafe ingredients found)
          if (unsafeIngredientsCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$unsafeIngredientsCount ingredient warning${unsafeIngredientsCount > 1 ? 's' : ''}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          
          // Health analysis
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text(
              analysis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 