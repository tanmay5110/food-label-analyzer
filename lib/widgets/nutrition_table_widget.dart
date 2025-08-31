import 'package:flutter/material.dart';

class NutritionTableWidget extends StatelessWidget {
  final Map<String, double> nutritionFacts;
  final Map<String, String> nutritionFactsWithUnits;
  
  const NutritionTableWidget({
    Key? key,
    required this.nutritionFacts,
    required this.nutritionFactsWithUnits,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Format nutrition facts in a readable order
    final List<MapEntry<String, String>> sortedFacts = _getSortedNutritionFacts();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nutrient',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          
          // Show message if no nutrition facts
          if (sortedFacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Nutrition information could not be extracted',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            // Show nutrition rows
            ...sortedFacts.map((entry) => _buildNutritionRow(entry.key, entry.value)),
        ],
      ),
    );
  }
  
  List<MapEntry<String, String>> _getSortedNutritionFacts() {
    // Define the display order for nutrients
    final displayOrder = [
      'calories', 'energy', 
      'fat', 'total_fat',
      'saturated_fat', 
      'trans_fat',
      'cholesterol',
      'sodium',
      'carbohydrates', 'total_carbohydrates',
      'fiber', 'dietary_fiber',
      'sugars',
      'protein',
      'vitamin_a', 'vitamin_c', 'vitamin_d',
      'calcium', 'iron', 'potassium'
    ];
    
    // If nutrition facts is empty, return empty list
    if (nutritionFactsWithUnits.isEmpty) {
      return [];
    }
    
    // Sort facts based on display order
    List<MapEntry<String, String>> sortedFacts = [];
    
    // First add facts in the proper order
    for (final key in displayOrder) {
      final matches = nutritionFactsWithUnits.entries.where(
        (entry) => entry.key.toLowerCase() == key.toLowerCase() || 
                   entry.key.toLowerCase().contains(key.toLowerCase())
      );
      
      if (matches.isNotEmpty) {
        sortedFacts.add(matches.first);
      }
    }
    
    // Add remaining facts not in the display order
    for (final entry in nutritionFactsWithUnits.entries) {
      if (!sortedFacts.any((e) => e.key == entry.key)) {
        sortedFacts.add(entry);
      }
    }
    
    return sortedFacts;
  }
  
  Widget _buildNutritionRow(String name, String valueWithUnit) {
    // Format the nutrient name for display
    String displayName = name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1) 
            : '')
        .join(' ');
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              displayName,
              style: TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              valueWithUnit,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
} 