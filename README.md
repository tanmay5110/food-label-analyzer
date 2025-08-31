# Food Label Analyzer

A Flutter application that analyzes food nutrition labels using Google's Gemini AI API. The app helps users understand the nutritional content and potential health concerns of packaged food products.

## Features
- Scan food nutrition labels using the camera or select from the gallery
- AI-powered analysis of ingredients and nutritional information
- Health score calculation (1-10)
- Identification of potentially unsafe ingredients
- Detailed nutritional information display
- User-friendly interface with intuitive navigation

## Prerequisites
- Flutter SDK (>=3.0.0)
- Google Gemini API key
- Android Studio / VS Code with Flutter extensions

## Setup

1. **Clone the repository:**
git clone https://github.com/yourusername/food_label_analyzer.git
cd food_label_analyzer

text

2. **Install dependencies:**
flutter pub get

text

3. **Configure API Key:**
- Get a Gemini API key from Google AI Studio
- Replace the API key in `lib/utils/constants.dart`

4. **Run the app:**
flutter run

text

## Dependencies
- image_picker: ^1.0.4
- http: ^1.1.0
- image: ^4.0.17
- flutter_image_compress: ^2.0.3
- connectivity_plus: ^6.1.3
- async: ^2.12.0

## Project Structure
lib/
├── main.dart # App entry point
├── models/ # Data models
├── screens/ # UI screens
├── services/ # API and image services
├── utils/ # Constants and utilities
└── widgets/ # Reusable UI components

text

## Usage

1. Launch the app
2. Choose to take a photo or select from the gallery
3. Position the food label in the camera view
4. Review the preview and tap "Analyze Label"
5. View the detailed analysis including:
   - Health score
   - Ingredients list
   - Nutritional information
   - Potential health concerns

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.