import 'package:flutter/material.dart';
import '../models/food_analysis_result.dart';
import '../widgets/unsafe_ingredients_widget.dart';
import '../widgets/nutrition_table_widget.dart';
import '../widgets/singapore_criteria_widget.dart';
import '../utils/constants.dart';
import '../widgets/nutrition_score_widget.dart';

class ResultsTabs extends StatelessWidget {
  final FoodAnalysisResult result;

  const ResultsTabs({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthColor = getHealthColorFromGrade(result.healthGrade);
    
    return DefaultTabController(
      length: 4, // Four tabs
      child: Column(
        children: [
          // Custom tab bar with improved design
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              labelColor: healthColor,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              indicatorColor: healthColor,
              isScrollable: false, // Make tabs fit width
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  icon: Icon(Icons.receipt_long, size: 18),
                  text: "INGREDIENTS",
                  iconMargin: const EdgeInsets.only(bottom: 2),
                  height: 56,
                ),
                Tab(
                  icon: Icon(Icons.table_chart, size: 18),
                  text: "NUTRITION",
                  iconMargin: const EdgeInsets.only(bottom: 2),
                  height: 56,
                ),
                Tab(
                  icon: Icon(Icons.health_and_safety, size: 18),
                  text: "STANDARDS",
                  iconMargin: const EdgeInsets.only(bottom: 2),
                  height: 56,
                ),
                Tab(
                  icon: Badge(
                    isLabelVisible: (result.unsafeIngredients?.length ?? 0) > 0,
                    label: Text(
                      (result.unsafeIngredients?.length ?? 0).toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    child: Icon(Icons.warning, size: 18),
                  ),
                  text: "WARNINGS",
                  iconMargin: const EdgeInsets.only(bottom: 2),
                  height: 56,
                ),
              ],
            ),
          ),
          
          // Tab content with proper scrolling
          Expanded(
            child: TabBarView(
              physics: const ClampingScrollPhysics(), // Allow proper scrolling
              children: [
                // Ingredients tab content
                _buildIngredientsTab(result),
                
                // Nutrition facts tab content
                _buildNutritionTab(result),
                
                // Singapore criteria tab content
                _buildSingaporeCriteriaTab(result),
                
                // Warnings tab content
                _buildWarningsTab(result),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(FoodAnalysisResult result) {
    // First, create a map of unsafe ingredients for quick lookups
    final Map<String, UnsafeIngredient> unsafeIngredientsMap = {};
    for (final ingredient in result.unsafeIngredients) {
      unsafeIngredientsMap[ingredient.name.toLowerCase()] = ingredient;
    }
    
    // Process ingredients to highlight unsafe ones
    List<Widget> ingredientWidgets = [];
    if (result.ingredients.isNotEmpty) {
      ingredientWidgets = result.ingredients.map((ingredient) {
        final String ingredientLower = ingredient.toLowerCase().trim();
        
        // Check if this ingredient is in the unsafe ingredients list
        UnsafeIngredient? unsafeMatch;
        unsafeIngredientsMap.forEach((key, value) {
          if (ingredientLower.contains(key) || key.contains(ingredientLower)) {
            unsafeMatch = value;
          }
        });
        
        if (unsafeMatch != null) {
          // Highlight unsafe ingredients based on severity
          Color textColor;
          switch (unsafeMatch!.severity.toLowerCase()) {
            case 'high':
              textColor = Colors.red[700]!;
              break;
            case 'medium':
              textColor = Colors.orange[700]!;
              break;
            case 'low':
              textColor = Colors.amber[700]!;
              break;
            default:
              textColor = Colors.grey[700]!;
          }
          
          return RichText(
            text: TextSpan(
              text: ingredient,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          // Normal ingredient
          return Text(
            ingredient,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          );
        }
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: AlwaysScrollableScrollPhysics(), // Ensure scrollable behavior
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Use minimum required space
        children: [
          // Existing ingredients section
          const Text(
            'Ingredients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Ingredients content
          if (result.ingredients.isNotEmpty) 
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ingredientWidgets.map((widget) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget,
                );
              }).toList(),
            )
          else
            const Text(
              'No ingredients information available',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            
          // Legend for color coding
          if (result.unsafeIngredients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Color Legend:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildLegendItem('High concern', Colors.red[700]!),
                  _buildLegendItem('Medium concern', Colors.orange[700]!),
                  _buildLegendItem('Low concern', Colors.amber[700]!),
                  const SizedBox(height: 8),
                  const Text(
                    'See "WARNINGS" tab for details on highlighted ingredients',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper method to build legend items
  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab(FoodAnalysisResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NutritionScoreWidget(grade: result.healthGrade),
          const SizedBox(height: 24),
          const Text(
            'Nutrition Facts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          NutritionTableWidget(
            nutritionFacts: result.nutritionFacts,
            nutritionFactsWithUnits: result.nutritionFactsWithUnits,
          ),
          
          // If nutrition facts are empty, add a suggestion
          if (result.nutritionFacts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
      child: Card(
                color: Colors.blue[50],
        child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Suggestion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try taking a clearer photo of the nutrition facts table. '
                        'Make sure it\'s well-lit and the text is readable.',
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSingaporeCriteriaTab(FoodAnalysisResult result) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Health Standards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Singapore criteria widget
          SingaporeCriteriaWidget(
            criteria: result.criteriaResults,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsTab(FoodAnalysisResult result) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Ingredient Warnings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Unsafe ingredients widget - now expanded to fill available space
          Expanded(
            child: UnsafeIngredientsWidget(
              unsafeIngredients: result.unsafeIngredients,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(FoodAnalysisResult result) {
    // ALWAYS use this implementation with no conditionals
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Grade section
          Container(
            width: double.infinity,
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
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getHealthGradeColor(result.healthGrade),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      result.healthGrade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Grade',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score: ${result.healthScore}/10',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Custom Analysis section - ALWAYS shows this content
          Container(
            width: double.infinity,
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
                Text(
                  'Nutritional Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Generate the analysis text on the fly - never use result.analysis
                Text(
                  'This ${result.productName} has a health grade of ${result.healthGrade} (${result.healthScore}/10). ' +
                  'Based on its nutritional profile, it ' +
                  (result.healthGrade == 'A' ? 'is an excellent food choice with high nutritional value.' :
                   result.healthGrade == 'B' ? 'is a good nutritional choice that fits well in a balanced diet.' :
                   result.healthGrade == 'C' ? 'has average nutritional quality and should be consumed in moderation.' :
                   result.healthGrade == 'D' ? 'has below average nutritional quality. Consider consuming only occasionally.' :
                   'has poor nutritional quality. It\'s best consumed rarely and in small amounts.'),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Consumption Advice section
          Container(
            width: double.infinity,
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
                    Icon(
                      Icons.restaurant,
                      color: _getHealthGradeColor(result.healthGrade),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Consumption Advice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getHealthGradeColor(result.healthGrade).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getHealthGradeColor(result.healthGrade).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hard-code the recommendations if consumptionAdvice is somehow missing
                      Text(
                        result.consumptionAdvice.isNotEmpty ? 
                          result.consumptionAdvice : 
                          _getFallbackConsumptionAdvice(result.healthGrade),
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add this fallback method to ensure we always have consumption advice
  String _getFallbackConsumptionAdvice(String grade) {
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

  Color _getHealthGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFF038141); // Dark Green
      case 'B': return const Color(0xFF85BB2F); // Light Green
      case 'C': return const Color(0xFFFECB02); // Yellow
      case 'D': return const Color(0xFFF39A1A); // Orange
      case 'E': return const Color(0xFFE63E11); // Red
      default: return Colors.grey;
    }
  }
} 