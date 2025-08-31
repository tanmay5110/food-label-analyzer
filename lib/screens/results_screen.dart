import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui';
import '../models/food_analysis_result.dart';
import '../widgets/health_score_display.dart';
import '../widgets/results_tabs.dart';
import '../utils/constants.dart';
import '../widgets/nutrition_score_widget.dart';

class ResultsScreen extends StatefulWidget {
  final FoodAnalysisResult result;
  final Uint8List imageBytes;
  
  const ResultsScreen({
    Key? key,
    required this.result,
    required this.imageBytes,
  }) : super(key: key);
  
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Animated color values for the background gradient
  final List<Color> _gradientStartColors = [
    const Color(0xFF6A11CB), // Purple for grade A
    const Color(0xFF2575FC), // Blue for grade B
    const Color(0xFFFFA41B), // Orange for grade C
    const Color(0xFFFF5757), // Red for grade D
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Animations for the score/grade reveal
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Slide animation for tabs
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animations with a slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
      _slideAnimationController.forward();
    });
  }
  
  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final healthColor = getHealthColorFromGrade(widget.result.healthGrade);
    final gradientColors = _getGradientColors(widget.result.healthGrade);
    final isSmallScreen = screenSize.height < 700; // Detect smaller screens
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background that reflects the health grade
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar with back button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: isSmallScreen ? 4 : 8
                  ),
                  child: Row(
                    children: [
                      _buildRippleButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Analysis Results',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildRippleButton(
                        onTap: () {
                  // Navigate back to home
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Top half of screen - Health score/grade display (not in Expanded)
                Container(
                  height: screenSize.height * 0.33, // Take roughly 1/3 of screen height
                  child: AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scoreAnimation.value,
                        child: child,
                      );
                    },
                    child: _buildGradeDisplay(
                      widget.result, 
                      widget.imageBytes, 
                      healthColor,
                      isSmallScreen
                    ),
                  ),
                ),
                
                // Bottom half of screen - Sliding up tab content
                Expanded(
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, screenSize.height * 0.2 * (1 - _slideAnimationController.value)),
                        child: Opacity(
                          opacity: _slideAnimationController.value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildResultsCard(widget.result),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Floating action button to scan another label
      floatingActionButton: AnimatedBuilder(
        animation: _slideAnimationController, 
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _slideAnimationController.value)),
            child: Opacity(
              opacity: _slideAnimationController.value,
              child: child,
            ),
          );
        },
        child: FloatingActionButton.extended(
          onPressed: () {
            // Navigate back to home
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          backgroundColor: Colors.white,
          foregroundColor: healthColor,
          elevation: 8,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scan Another'),
        ),
      ),
    );
  }
  
  Widget _buildRippleButton({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: child,
      ),
    );
  }
  
  Widget _buildGradeDisplay(FoodAnalysisResult result, Uint8List imageBytes, Color healthColor, bool isSmallScreen) {
    final gradeDescription = FoodAnalysisResult.getGradeDescription(result.healthGrade);
    
    return Container(
      margin: EdgeInsets.fromLTRB(
        16, 
        isSmallScreen ? 4 : 0, 
        16, 
        isSmallScreen ? 8 : 16
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isSmallScreen ? 12 : 16
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Image and grade side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image with animated border
                    Hero(
                      tag: 'previewImage',
                      child: Container(
                        height: isSmallScreen ? 50 : 70,
                        width: isSmallScreen ? 50 : 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Grade and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grade badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGradeBadge(result.healthGrade, healthColor, isSmallScreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HEALTH GRADE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 10 : 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      gradeDescription,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 12 : 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Warnings indicator
                          if (result.unsafeIngredients != null && result.unsafeIngredients!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: isSmallScreen ? 12 : 14,
                                  ),
                                  SizedBox(width: isSmallScreen ? 2 : 4),
                                  Text(
                                    "${result.unsafeIngredients!.length} warning${result.unsafeIngredients!.length > 1 ? 's' : ''}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 10 : 12,
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
                
                const SizedBox(height: 12),
                
                // Health analysis
                if (result.analysis != null && result.analysis!.isNotEmpty)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            result.analysis!,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nutritional Analysis',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This product has a health grade of ${result.healthGrade} with a score of ${result.healthScore}/10. ' +
                            _getMicroQualityDescription(result.healthGrade),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Recommended consumption frequency:',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getUltraShortConsumptionAdvice(result.healthGrade),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildGradeBadge(String grade, Color color, bool isSmallScreen) {
    final badgeSize = isSmallScreen ? 40.0 : 50.0;
    final innerSize = isSmallScreen ? 34.0 : 42.0;
    final fontSize = isSmallScreen ? 20.0 : 26.0;
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 360),
      duration: const Duration(seconds: 2),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Container(
          height: badgeSize,
          width: badgeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.5),
              ],
              stops: const [0.75, 1.0],
              transform: GradientRotation(math.pi * 2 * value / 360),
            ),
          ),
          child: Center(
            child: Container(
              height: innerSize,
              width: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  grade,
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
                  ),
                ),
              );
            },
    );
  }
  
  Widget _buildResultsCard(FoodAnalysisResult result) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: ResultsTabs(result: result),
    );
  }
  
  List<Color> _getGradientColors(String grade) {
    // Get gradient colors based on the health grade
    switch (grade) {
      case 'A':
        return [
          const Color(0xFF6A11CB), // Purple
          const Color(0xFF5F20AD),
        ];
      case 'B':
        return [
          const Color(0xFF2575FC), // Blue
          const Color(0xFF1A56B9),
        ];
      case 'C':
        return [
          const Color(0xFFFFA41B), // Orange
          const Color(0xFFE5880E),
        ];
      case 'D':
        return [
          const Color(0xFFFF5757), // Red
          const Color(0xFFD12F2F),
        ];
      default:
        return [
          const Color(0xFF2575FC), // Default blue
          const Color(0xFF1A56B9),
        ];
    }
  }
  
  String _getMicroQualityDescription(String grade) {
    switch (grade) {
      case 'A': return 'Excellent nutritional quality.';
      case 'B': return 'Good nutritional quality.';
      case 'C': return 'Average nutritional quality.';
      case 'D': return 'Below average nutritional quality.';
      case 'E': return 'Poor nutritional quality.';
      default: return 'Nutritional quality could not be fully assessed.';
    }
  }
  
  String _getUltraShortConsumptionAdvice(String grade) {
    switch (grade) {
      case 'A': return 'Consume regularly (4-7x/week). Excellent choice for daily diet.';
      case 'B': return 'Consume frequently (2-4x/week). Good for balanced diet.';
      case 'C': return 'Consume moderately (1-2x/week). Balance with healthier options.';
      case 'D': return 'Consume occasionally (1-2x/month). Limit portions.';
      case 'E': return 'Consume rarely (<1x/month). Find healthier alternatives.';
      default: return 'Consume as part of a varied diet.';
    }
  }
  
  Color _getHealthGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFF038141);
      case 'B': return const Color(0xFF85BB2F);
      case 'C': return const Color(0xFFFECB02);
      case 'D': return const Color(0xFFF39A1A);
      case 'E': return const Color(0xFFE63E11);
      default: return Colors.grey;
    }
  }
  
  void _showAnalysisDialog(BuildContext context, FoodAnalysisResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Product Analysis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grade: ${result.healthGrade} (${result.healthScore}/10)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_getMicroQualityDescription(result.healthGrade)),
            SizedBox(height: 16),
            Text(
              'Consumption Advice:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(result.consumptionAdvice),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
} 