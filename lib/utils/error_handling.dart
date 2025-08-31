import 'package:flutter/material.dart';
import 'dart:typed_data';

void showInvalidLabelDialog({
  required BuildContext context, 
  required String message,
  Uint8List? imageBytes,
  VoidCallback? onTryAgain,
}) {
  // Determine error type and customize title/icon
  String title = 'Not a Food Label';
  IconData iconData = Icons.error_outline;
  Color iconColor = Colors.orange.shade700;
  
  if (message.contains("missing required nutrition")) {
    title = 'Incomplete Label';
    iconData = Icons.menu_book_outlined;
    iconColor = Colors.amber.shade700;
  } else if (message.contains("error") || message.contains("Error")) {
    title = 'Analysis Error';
    iconData = Icons.warning_amber_rounded;
    iconColor = Colors.red.shade700;
  }
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      title: Row(
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Optional: Show the image that was uploaded
              if (imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 80,
                      maxWidth: double.infinity,
                    ),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              // Show specific guidance based on error type
              if (message.contains("missing required nutrition"))
                Text(
                  'Make sure the image shows both ingredients and nutrition facts.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              if (message.contains("doesn't appear to be a food"))
                Text(
                  'Try again with a packaged food product label.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL', style: TextStyle(fontSize: 12)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            if (onTryAgain != null) {
              onTryAgain();
            }
          },
          icon: const Icon(Icons.camera_alt, size: 16),
          label: const Text('TRY AGAIN', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    ),
  );
} 