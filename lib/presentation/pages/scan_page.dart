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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pindai Gambar'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImagePlaceholderWidget(
                      capturedImage: _capturedImage,
                      onTap: _showImageSourceDialog,
                    ),
                    if (_capturedImage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ketuk gambar di atas untuk mengganti foto',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Tambahan (Opsional)',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _isListening
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade300,
                          width: _isListening ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isListening
                                        ? const Color(0xFF4CAF50)
                                        : Colors.black)
                                    .withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _infoController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText:
                                    'Contoh: Nasi goreng dengan telur, porsi sedang...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: _isListening
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF4CAF50),
                                        Color(0xFF66BB6A),
                                      ],
                                    )
                                  : null,
                              color: _isListening ? null : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              boxShadow: _isListening
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF4CAF50,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                                color: _isListening
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 24,
                              ),
                              onPressed: _toggleListening,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isListening) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 800),
                                  builder: (context, value, child) {
                                    return Icon(
                                      Icons.graphic_eq_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Mendengarkan...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
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
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleScanSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Lanjutkan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
