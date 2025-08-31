import 'package:flutter/material.dart';

class NutritionScoreWidget extends StatelessWidget {
  final String grade;
  
  const NutritionScoreWidget({
    Key? key,
    required this.grade,
  }) : super(key: key);

  Color _getScoreColor() {
    switch (grade) {
      case 'A': return const Color(0xFF038141); // Dark Green
      case 'B': return const Color(0xFF85BB2F); // Light Green
      case 'C': return const Color(0xFFFECB02); // Yellow
      case 'D': return const Color(0xFFF39A1A); // Orange
      case 'E': return const Color(0xFFE63E11); // Red
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Text(
                'Nutri-Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
                tooltip: 'About Nutri-Score',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['A', 'B', 'C', 'D', 'E'].map((letter) {
              bool isSelected = letter == grade;
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? _getScoreColor() : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _getGradeDescription(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getScoreColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGradeDescription() {
    switch (grade) {
      case 'A': return 'Excellent nutritional quality';
      case 'B': return 'Good nutritional quality';
      case 'C': return 'Average nutritional quality';
      case 'D': return 'Below average nutritional quality';
      case 'E': return 'Poor nutritional quality';
      default: return 'Unknown nutritional quality';
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Nutri-Score'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nutri-Score is a front-of-pack label that converts the nutritional value of products into a simple code consisting of 5 letters.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 12),
              Text('The score is based on a scientific algorithm that considers:'),
              SizedBox(height: 8),
              Text('• Energy value'),
              Text('• Sugars'),
              Text('• Saturated fatty acids'),
              Text('• Sodium'),
              Text('• Fiber'),
              Text('• Protein'),
              SizedBox(height: 12),
              Text(
                'A (Green) = Highest nutritional quality\n'
                'B (Light Green) = Good nutritional quality\n'
                'C (Yellow) = Average nutritional quality\n'
                'D (Orange) = Low nutritional quality\n'
                'E (Red) = Lowest nutritional quality',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 