import 'dart:io';

import 'package:flutter/material.dart';

class ImagePlaceholderWidget extends StatelessWidget {
  final File? capturedImage;
  final VoidCallback onTap;

  const ImagePlaceholderWidget({
    super.key,
    required this.capturedImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          gradient: capturedImage == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    const Color(0xFF66BB6A).withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: capturedImage != null ? Colors.grey.shade100 : null,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: capturedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ketuk untuk ambil gambar',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Foto makanan atau minuman Anda',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: Image.file(
                  capturedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }
}

class XPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final _ = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
