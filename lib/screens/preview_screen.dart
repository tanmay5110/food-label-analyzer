import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/custom_buttons.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/error_handling.dart';
import 'results_screen.dart';
import '../models/food_analysis_result.dart';

class PreviewScreen extends StatefulWidget {
  final XFile image;
  final Uint8List imageBytes;
  
  const PreviewScreen({
    Key? key,
    required this.image,
    required this.imageBytes,
  }) : super(key: key);
  
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isImageFocused = false;
  bool _isCropping = false;
  final ApiService _apiService = ApiService(apiKey: apiKey);
  late AnimationController _animationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  // Store the current image bytes (may be updated after cropping)
  late Uint8List _currentImageBytes;
  
  // Variables to track loading progress
  int _analysisStep = 0;
  final List<String> _analysisSteps = [
    'Preparing image...',
    'Uploading to AI...',
    'Analyzing ingredients...',
    'Evaluating nutrition...',
    'Finalizing results...'
  ];
  
  FoodAnalysisResult? _result;  // Add this field
  
  @override
  void initState() {
    super.initState();
    // Initialize with the original image bytes
    _currentImageBytes = widget.imageBytes;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Stack(
          children: [
            // Blurred background with image
            SizedBox.expand(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(_currentImageBytes),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.65),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom app bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Back button with ripple effect
                        _buildRippleButton(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Preview Label',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        // Crop button
                        _buildRippleButton(
                          onTap: _cropImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.crop,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Image display area with glowing effect when focused
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isImageFocused ? 1.0 : _pulseAnimation.value,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isImageFocused = true);
                                _showFullScreenImage();
                              },
                              child: Hero(
                                tag: 'previewImage',
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Inner shadow/glow
                                    if (!_isImageFocused)
                                      Container(
                                        margin: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.25),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // Image with border
                                    Container(
                                      margin: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.25),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.4),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.memory(
                                          _currentImageBytes,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    
                                    // Zoom indicator
                                    if (!_isImageFocused)
                                      Positioned(
                                        bottom: 40,
                                        right: 40,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                'Tap to zoom',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
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
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Bottom action area with glass effect
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status indicator
                            Row(
                              children: [
                                Container(
                                  height: 6,
                                  width: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Ready to analyze',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Instructions
                            Text(
                              'Analyze Food Label',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Our AI will extract nutrition facts and provide health analysis of this product.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Analyze button
                            _buildAnalyzeButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading overlay with animated particles
            if (_isLoading || _isCropping)
              _buildLoadingOverlay(screenSize, _isCropping),
          ],
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
  
  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || _isCropping ? null : _analyzeImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2575FC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          shadowColor: const Color(0xFF2575FC).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 18),
            const SizedBox(width: 8),
            Text(
              'Analyze Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingOverlay(Size screenSize, bool isCropping) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom loading animation
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2575FC).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    
                    // Outer rotating circle
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 2 * 3.14159,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2575FC).withOpacity(0.5),
                                width: 4,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                              gradient: SweepGradient(
                                colors: [
                                  const Color(0xFF6A11CB).withOpacity(0),
                                  const Color(0xFF6A11CB),
                                ],
                                stops: const [0.7, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Middle rotating circle (opposite direction)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_animationController.value * 3.14159,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Inner pulsing circle
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2575FC).withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2575FC).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              isCropping ? Icons.crop : Icons.local_dining_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Small orbiting dots
                    ...List.generate(
                      4,
                      (index) => AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final angle = (_animationController.value * 2 * 3.14159) + (index * 3.14159 / 2);
                          return Transform.translate(
                            offset: Offset(
                              45 * cos(angle),
                              45 * sin(angle),
                            ),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Loading title
              Text(
                isCropping ? 'Cropping Image' : 'Analyzing Food Label',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Show step indicator only when analyzing (not cropping)
              if (!isCropping) ...[
                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _analysisSteps.length, 
                    (index) => Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= _analysisStep 
                          ? const Color(0xFF2575FC) 
                          : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Current step description
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _analysisSteps[_analysisStep],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Estimated time
                Text(
                  "Estimated time: 10-15 seconds",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ] else ...[
                // Text for cropping mode
                Text(
                  'Please wait while we process your image...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _showFullScreenImage() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image viewer
            GestureDetector(
              onTap: () {
                setState(() => _isImageFocused = false);
                Navigator.pop(context);
              },
              child: Hero(
                tag: 'previewImage',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    _currentImageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() => _isImageFocused = false);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            
            // Crop button
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _cropImage();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.crop,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            
            // Instructions
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Pinch to zoom • Double tap to reset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        _isImageFocused = false;
      });
    });
  }
  
  // Image cropping functionality
  Future<void> _cropImage() async {
    try {
      setState(() {
        _isCropping = true;
      });
      
      if (kIsWeb) {
        // Web implementation - since the existing code doesn't work well on web,
        // we'll show a simple snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image cropping is only available in the mobile app.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isCropping = false;
        });
        return;
      }
      
      // Mobile implementation
      // Create a temporary file from the image bytes
      final tempDir = await Directory.systemTemp.createTemp('crop_image');
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(_currentImageBytes);
      
      // Open the image cropper
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        compressQuality: 90,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Food Label',
            toolbarColor: const Color(0xFF2575FC),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: const Color(0xFF2575FC),
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Food Label',
            aspectRatioLockEnabled: false,
            minimumAspectRatio: 1.0,
            resetAspectRatioEnabled: true,
          ),
        ],
      );
      
      // Clean up temporary files
      await tempFile.delete();
      await tempDir.delete(recursive: true);
      
      // If cropping was successful, update the image
      if (croppedFile != null) {
        final croppedBytes = await croppedFile.readAsBytes();
        setState(() {
          _currentImageBytes = croppedBytes;
        });
      }
      
    } catch (e) {
      // Show error if cropping fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image cropping failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCropping = false;
      });
    }
  }
  
  // Method to advance the loading step with animation
  void _advanceLoadingStep() {
    if (_analysisStep < _analysisSteps.length - 1) {
      setState(() {
        _analysisStep++;
      });
    }
  }
  
  Future<void> _analyzeImage() async {
    setState(() {
      _isLoading = true;
      _analysisStep = 0; // Reset step counter
    });
    
    // Start the step animation
    Future.delayed(const Duration(seconds: 1), () {
      if (_isLoading) _advanceLoadingStep();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading) _advanceLoadingStep();
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (_isLoading) _advanceLoadingStep();
    });
    Future.delayed(const Duration(seconds: 9), () {
      if (_isLoading) _advanceLoadingStep();
    });
    
    try {
      // Compress image before sending to the API
      final compressedImageBytes = await compressImage(_currentImageBytes);
      
      final result = await _apiService.analyzeFoodLabel(compressedImageBytes)
          .timeout(
            const Duration(seconds: 30), // Reduced timeout
            onTimeout: () {
              throw TimeoutException('Analysis took too long. Please try again.');
            },
          );
      
      setState(() {
        _isLoading = false;
        _result = result;
      });
      
      if (!result.isValidFoodLabel) {
        // Show error dialog if not a valid food label
        showInvalidLabelDialog(
          context: context,
          message: result.errorMessage ?? "This doesn't appear to be a food label.",
          imageBytes: _currentImageBytes,
          onTryAgain: () {
            Navigator.pop(context); // Pop back to home screen
          },
        );
      } else {
        // Navigate to results screen with transition
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) {
              return FadeTransition(
                opacity: animation,
                child: ResultsScreen(
                  result: result,
                  imageBytes: _currentImageBytes,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error dialog with improved styling
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.shade300.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Analysis Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result?.errorMessage ?? "This doesn't appear to be a food label.",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
} 