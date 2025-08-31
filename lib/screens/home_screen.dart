import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:math' as math;
import '../widgets/custom_buttons.dart';
import '../services/image_service.dart';
import 'preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ImageService imageService = ImageService();
  late AnimationController _backgroundAnimationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _floatingAnimation;
  
  // Animation values
  final List<Color> _gradientColors = [
    const Color(0xFF2F2FAD), // Deep blue
    const Color(0xFF5A6BFF), // Bright blue
  ];

  final List<Color> _accentColors = [
    const Color(0xFF8A64FF), // Purple accent
    const Color(0xFF6AECFF), // Cyan accent
  ];
  
  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _floatingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                width: screenSize.width,
                height: screenSize.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientColors,
                    transform: GradientRotation(
                      _backgroundAnimationController.value * math.pi * 0.5
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Subtle flowing waves
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavesPainter(
                    animationValue: _backgroundAnimationController.value,
                    colors: [
                      _accentColors[0].withOpacity(0.15),
                      _accentColors[1].withOpacity(0.1),
                    ],
                  ),
                  size: Size(screenSize.width, screenSize.height),
                );
              },
            ),
          ),
          
          // Content Layer
          SafeArea(
            child: Column(
              children: [
                // App Bar section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Empty spacer for balance
                      const SizedBox(width: 40),
                      
                      // Centered title
                      const Text(
                        'NutriScan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      // Info button positioned at the right
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white),
                        onPressed: () {
                          _showInfoDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo/Icon
                            _buildLogoAnimation(),
                            const SizedBox(height: 40),
                            
                            // Title and Description
                            Text(
                              'Food Label Scanner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Analyze food labels instantly and make healthier choices',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            
                            // Buttons
                            _buildOptionButtons(context),
                            
                            const SizedBox(height: 40),
                            
                            // Info Text
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Ensure the label includes both ingredients and nutrition facts',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoAnimation() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * -10),
          child: Container(
            width: 140,
            height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _accentColors[1].withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accentColors[0].withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.qr_code_scanner,
                size: 70,
                color: _gradientColors[0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _getImage(context, ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose from Gallery'),
          style: ElevatedButton.styleFrom(
            foregroundColor: _gradientColors[0],
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!kIsWeb) // Camera option only for mobile
          ElevatedButton.icon(
            onPressed: () => _getImage(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a Photo'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _accentColors[0].withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
              ),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.2),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'About Food Label Scanner',
                style: TextStyle(
                  color: _gradientColors[0],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This app helps you analyze food nutrition labels to make healthier choices. '
                'Scan a label and get detailed nutrition information, health grading, '
                'and alerts about potentially unsafe ingredients.',
                  style: TextStyle(
                    fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF5A6BFF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final XFile? selectedImage = await imageService.pickImage(source);
    
    if (selectedImage != null && mounted) {
      final imageBytes = await imageService.getImageBytes(selectedImage);
      
      if (imageBytes != null) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) {
              return FadeTransition(
                opacity: animation,
                child: PreviewScreen(
              image: selectedImage,
              imageBytes: imageBytes,
            ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }
}

// Subtle flowing waves background painter
class WavesPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  
  WavesPainter({required this.animationValue, required this.colors});
  
  @override
  void paint(Canvas canvas, Size size) {
    // First wave
    final paint1 = Paint()
      ..color = colors[0]
      ..style = PaintingStyle.fill;
    
    final path1 = Path();
    
    final waveHeight1 = size.height * 0.15;
    final waveCount1 = 3;
    
    path1.moveTo(0, size.height * 0.4 + math.sin(animationValue * math.pi * 2) * waveHeight1);
    
    for (int i = 0; i <= waveCount1; i++) {
      final dx = size.width / waveCount1 * i;
      final dy = size.height * 0.4 + 
                math.sin((animationValue * math.pi * 2) + (i / waveCount1) * math.pi * 4) * 
                waveHeight1;
      
      path1.lineTo(dx, dy);
    }
    
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    
    canvas.drawPath(path1, paint1);
    
    // Second wave
    final paint2 = Paint()
      ..color = colors[1]
      ..style = PaintingStyle.fill;
    
    final path2 = Path();
    
    final waveHeight2 = size.height * 0.2;
    final waveCount2 = 4;
    
    path2.moveTo(0, size.height * 0.6 + math.cos(animationValue * math.pi * 2 + math.pi) * waveHeight2);
    
    for (int i = 0; i <= waveCount2; i++) {
      final dx = size.width / waveCount2 * i;
      final dy = size.height * 0.6 + 
                math.cos((animationValue * math.pi * 2) + (i / waveCount2) * math.pi * 3 + math.pi) * 
                waveHeight2;
      
      path2.lineTo(dx, dy);
    }
    
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }
  
  @override
  bool shouldRepaint(WavesPainter oldDelegate) => true;
} 