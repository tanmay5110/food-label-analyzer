import 'package:flutter/material.dart';

class IngredientsWidget extends StatelessWidget {
  final String ingredients;
  
  const IngredientsWidget({
    Key? key,
    required this.ingredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Let Gemini analyze the ingredients text for harmful ingredients
    // It should return a list of ingredients with a "concern" level
    // We'll simulate this by highlighting common concerning ingredients
    
    final concerningIngredients = [
      {'name': 'High Fructose Corn Syrup', 'level': 'high'},
      {'name': 'MSG', 'level': 'high'},
      {'name': 'Artificial Colors', 'level': 'high'},
      {'name': 'Sodium Nitrite', 'level': 'high'},
      {'name': 'Hydrogenated Oil', 'level': 'high'},
      {'name': 'Trans Fat', 'level': 'high'},
      {'name': 'BHA', 'level': 'high'},
      {'name': 'BHT', 'level': 'high'},
      {'name': 'Aspartame', 'level': 'high'},
      {'name': 'Saccharin', 'level': 'medium'},
      {'name': 'Carrageenan', 'level': 'medium'},
      {'name': 'Potassium Sorbate', 'level': 'medium'},
      {'name': 'Sodium Benzoate', 'level': 'medium'},
      {'name': 'Soy Lecithin', 'level': 'low'},
      {'name': 'Natural Flavors', 'level': 'low'},
    ];
    
    // Create a list of TextSpans to highlight harmful ingredients
    List<TextSpan> textSpans = [];
    
    // Current processing text
    String remainingText = ingredients;
    
    for (final concern in concerningIngredients) {
      final name = concern['name']!;
      final level = concern['level']!;
      
      // Check if this concerning ingredient is in the text
      if (remainingText.toLowerCase().contains(name.toLowerCase())) {
        final regex = RegExp(name, caseSensitive: false);
        final matches = regex.allMatches(remainingText);
        
        int lastEnd = 0;
        
        for (final match in matches) {
          // Add text before the match
          if (match.start > lastEnd) {
            textSpans.add(TextSpan(
              text: remainingText.substring(lastEnd, match.start),
            ));
          }
          
          // Add the highlighted match
          Color highlightColor;
          switch (level) {
            case 'high':
              highlightColor = Colors.red.shade300;
              break;
            case 'medium':
              highlightColor = Colors.orange.shade300;
              break;
            case 'low':
            default:
              highlightColor = Colors.yellow.shade300;
              break;
          }
          
          textSpans.add(TextSpan(
            text: remainingText.substring(match.start, match.end),
            style: TextStyle(
              backgroundColor: highlightColor,
              fontWeight: FontWeight.bold,
            ),
          ));
          
          lastEnd = match.end;
        }
        
        // Update remaining text
        if (lastEnd < remainingText.length) {
          remainingText = remainingText.substring(lastEnd);
        } else {
          remainingText = '';
        }
      }
    }
    
    // Add any remaining text
    if (remainingText.isNotEmpty) {
      textSpans.add(TextSpan(text: remainingText));
    }
    
    // If no highlighting was done, just show the original text
    if (textSpans.isEmpty) {
      textSpans.add(TextSpan(text: ingredients));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: textSpans),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ingredient Concern Levels:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem('High', Colors.red.shade300),
            const SizedBox(width: 12),
            _buildLegendItem('Medium', Colors.orange.shade300),
            const SizedBox(width: 12),
            _buildLegendItem('Low', Colors.yellow.shade300),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
} 