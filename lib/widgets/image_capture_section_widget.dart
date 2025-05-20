import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ImageCaptureSection extends StatelessWidget {
  final CameraController? cameraController;
  final bool isCameraReady;
  final bool isProcessing;
  final List<File> capturedImages;
  final VoidCallback onCaptureImage;
  final Function(int) onRemoveImage;
  final Function(String) onShowFullScreenImage;

  const ImageCaptureSection({
    Key? key,
    required this.cameraController,
    required this.isCameraReady,
    required this.isProcessing,
    required this.capturedImages,
    required this.onCaptureImage,
    required this.onRemoveImage,
    required this.onShowFullScreenImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady || cameraController == null) return const SizedBox();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CameraPreview(cameraController!),
        ),
        ElevatedButton.icon(
          onPressed: isProcessing ? null : onCaptureImage,
          icon: const Icon(Icons.camera),
          label: const Text("التقط صورة"),
        ),
        if (capturedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: capturedImages.length,
              itemBuilder: (context, imgIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GestureDetector(
                        onTap: () => onShowFullScreenImage(
                            capturedImages[imgIndex].path),
                        child: Image.file(
                          capturedImages[imgIndex],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.red),
                        onPressed: () => onRemoveImage(imgIndex),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
