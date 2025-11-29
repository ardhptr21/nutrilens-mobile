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
        height: 220,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.green.shade400, width: 1.5),
        ),
        child: capturedImage == null
            ? Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 220),
                    painter: XPatternPainter(),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ketuk untuk mengambil gambar',
                          style: TextStyle(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(capturedImage!, fit: BoxFit.cover),
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
