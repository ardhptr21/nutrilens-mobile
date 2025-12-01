import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';

class ConfirmNutritionPage extends StatefulWidget {
  final NutritionScanResponse scanResult;
  final File capturedImage;
  final String? description;

  const ConfirmNutritionPage({
    super.key,
    required this.scanResult,
    required this.capturedImage,
    this.description,
  });

  @override
  State<ConfirmNutritionPage> createState() => _ConfirmNutritionPageState();
}

class _ConfirmNutritionPageState extends State<ConfirmNutritionPage> {
  final _formKey = GlobalKey<FormState>();
  final NutritionService _nutritionService = locator<NutritionService>();

  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.scanResult.name);
    _caloriesController = TextEditingController(
      text: widget.scanResult.cal.toStringAsFixed(1),
    );
    _proteinController = TextEditingController(
      text: widget.scanResult.protein.toStringAsFixed(1),
    );
    _fatController = TextEditingController(
      text: widget.scanResult.fat.toStringAsFixed(1),
    );
    _carbsController = TextEditingController(
      text: widget.scanResult.carbs.toStringAsFixed(1),
    );
    _descriptionController = TextEditingController(
      text: widget.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uploadRequest = NutritionUploadMealRequest(
        name: _nameController.text.trim(),
        cal: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        fat: double.parse(_fatController.text),
        carbs: double.parse(_carbsController.text),
        description: _descriptionController.text.trim(),
        image: widget.capturedImage,
      );

      final response = await _nutritionService.uploadMeal(uploadRequest);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Nutrisi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            widget.capturedImage,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildLabel('Nama Makanan'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama makanan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama makanan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Kalori (kcal)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _caloriesController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan kalori',
                          prefixIcon: Icon(
                            Icons.local_fire_department,
                            color: Colors.green.shade700,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kalori tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Informasi Nutrisi'),
                      const SizedBox(height: 12),

                      _buildNutrientField(
                        controller: _proteinController,
                        label: 'Protein (g)',
                        icon: Icons.set_meal,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(height: 12),

                      _buildNutrientField(
                        controller: _fatController,
                        label: 'Lemak (g)',
                        icon: Icons.opacity,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(height: 12),

                      _buildNutrientField(
                        controller: _carbsController,
                        label: 'Karbohidrat (g)',
                        icon: Icons.rice_bowl,
                        color: Colors.blue.shade700,
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Deskripsi (Opsional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan catatan atau deskripsi...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleConfirm,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Konfirmasi'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildNutrientField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label tidak boleh kosong';
        }
        if (double.tryParse(value) == null) {
          return 'Masukkan angka yang valid';
        }
        return null;
      },
    );
  }
}
