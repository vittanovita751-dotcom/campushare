import 'package:flutter/material.dart';
import '../student_data.dart';

/// Widget gambar barang yang otomatis memilih antara asset lokal dan network image.
class ItemImage extends StatelessWidget {
  final StudentItem item;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ItemImage({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  Widget _buildImage() {
    if (item.isAsset) {
      return Image.asset(
        item.imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    } else {
      return Image.network(
        item.imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: _buildImage(),
      );
    }
    return _buildImage();
  }
}
