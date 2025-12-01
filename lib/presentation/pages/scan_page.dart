import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';
import 'package:nutrilens/presentation/pages/confirm_nutrition_page.dart';
import 'package:nutrilens/presentation/widgets/scan/image_placeholder_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _infoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final NutritionService _nutritionService = locator<NutritionService>();

  File? _capturedImage;
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _infoController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      _showErrorDialog('Pengenalan suara tidak tersedia di perangkat ini.');
      return;
    }

    await _speech.listen(
      onResult: (result) {
        final spoken = result.recognizedWords.trim();

        if (spoken.isEmpty) return;

        if (result.finalResult) {
          setState(() {
            final current = _infoController.text.trim();

            if (current.isEmpty) {
              _infoController.text = spoken;
            } else {
              _infoController.text = '$current $spoken';
            }
          });
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        onDevice: false,
      ),
      pauseFor: const Duration(seconds: 2),
      localeId: 'id_ID',
    );

    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _toggleListening() {
    _isListening ? _stopListening() : _startListening();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) return _openCamera();

    final isPermanent = status.isPermanentlyDenied;

    _showPermissionDialog(
      isPermanent ? 'Izin Kamera Ditolak' : 'Izin Kamera Diperlukan',
      isPermanent
          ? 'Izin kamera ditolak secara permanen. Buka pengaturan untuk mengaktifkan.'
          : 'Silakan berikan izin kamera untuk mengambil foto.',
      showSettings: isPermanent,
    );
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() => _capturedImage = File(photo.path));
      }
    } catch (e) {
      _showErrorDialog('Gagal menangkap gambar: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _capturedImage = File(image.path));
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _requestCameraPermission();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(
    String title,
    String msg, {
    bool showSettings = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(showSettings ? 'Buka Pengaturan' : 'Berikan Izin'),
            onPressed: () {
              Navigator.pop(context);
              showSettings ? openAppSettings() : _requestCameraPermission();
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScanSubmit() async {
    if (_capturedImage == null) {
      _showErrorDialog('Silakan pilih gambar terlebih dahulu.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = NutritionScanRequest(
        image: _capturedImage!,
        detail: _infoController.text.trim(),
      );

      final response = await _nutritionService.nutritionScan(request);

      if (!mounted) return;

      if (response.success && response.data != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmNutritionPage(
              scanResult: response.data!,
              capturedImage: _capturedImage!,
              description: _infoController.text.trim(),
            ),
          ),
        );
      } else {
        _showErrorDialog(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pindai Gambar'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImagePlaceholderWidget(
                      capturedImage: _capturedImage,
                      onTap: _showImageSourceDialog,
                    ),
                    if (_capturedImage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Ketuk gambar di atas untuk mengganti foto.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Informasi Tambahan (Optional)',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.only(bottom: 8, right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isListening
                              ? Colors.green
                              : Colors.grey.shade400,
                          width: _isListening ? 2.5 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 48),
                            child: TextField(
                              controller: _infoController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(12),
                                hintText: 'Tambahkan informasi tambahan...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? Colors.green
                                    : Colors.grey.shade600,
                              ),
                              onPressed: _toggleListening,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleScanSubmit,
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
                            : const Text('Lanjutkan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
