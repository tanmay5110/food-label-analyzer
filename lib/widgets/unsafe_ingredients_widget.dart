import 'package:flutter/material.dart';
import '../models/food_analysis_result.dart';

class UnsafeIngredientsWidget extends StatelessWidget {
  final List<UnsafeIngredient>? unsafeIngredients;

  const UnsafeIngredientsWidget({
    Key? key,
    required this.unsafeIngredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add debug logging
    print("Building UnsafeIngredientsWidget with ${unsafeIngredients?.length ?? 0} ingredients");
    
    if (unsafeIngredients == null || unsafeIngredients!.isEmpty) {
      return Card(
        elevation: 2,
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NO CONCERNING INGREDIENTS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'No potentially harmful ingredients detected for daily consumption.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Sort ingredients by severity (high to low)
    final sortedIngredients = List<UnsafeIngredient>.from(unsafeIngredients!);
    sortedIngredients.sort((a, b) {
      int aValue = _getSeverityValue(a.severity);
      int bValue = _getSeverityValue(b.severity);
      return bValue.compareTo(aValue); // Descending order
    });
    
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'INGREDIENT WARNINGS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${sortedIngredients.length} found',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Information text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'The following ingredients may be concerning for regular consumption:',
            style: TextStyle(fontSize: 14),
          ),
        ),
        
        // Warning cards
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortedIngredients.map((ingredient) => 
              _buildIngredientWarning(ingredient)
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientWarning(UnsafeIngredient ingredient) {
    Color severityColor = _getSeverityColorObject(ingredient.severity);
    IconData severityIcon = _getSeverityIcon(ingredient.severity);
    String severityText = ingredient.severity.toUpperCase();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: severityColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with severity indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(severityIcon, color: severityColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: severityColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      '$severityText RISK',
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Concern
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Concern: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          ingredient.concern.isNotEmpty ? ingredient.concern : "General health concern",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Explanation
                  Text(
                    ingredient.explanation.isNotEmpty ? ingredient.explanation : "No detailed explanation available.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColorObject(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red[700]!;
      case 'medium':
        return Colors.orange[700]!;
      case 'low':
        return Colors.amber[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
  
  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Icons.dangerous;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }
  
  int _getSeverityValue(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }
} 