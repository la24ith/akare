import "dart:io";
import "package:flutter/material.dart";
import "../../domain/entities/property_image_entity.dart";

class PropertyImagesGrid extends StatelessWidget {
  final List<PropertyImageEntity> images;
  final VoidCallback onAdd;
  final void Function(PropertyImageEntity) onRemove;
  final void Function(PropertyImageEntity) onSetPrimary;
  final bool isUploading;

  const PropertyImagesGrid({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    required this.onSetPrimary,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: images.length + 1,
      itemBuilder: (context, index) {
        if (index == images.length) {
          return GestureDetector(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
            ),
          );
        }
        final img = images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: img.isUploaded
                  ? Image.network(img.remoteUrl!, fit: BoxFit.cover)
                  : Image.file(File(img.localPath!), fit: BoxFit.cover),
            ),
            if (img.isPrimary)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E6E5C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("رئيسية",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: () => onRemove(img),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
            if (!img.isPrimary)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onSetPrimary(img),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "تعيين كرئيسية",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
