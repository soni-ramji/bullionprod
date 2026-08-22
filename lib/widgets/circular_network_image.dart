import 'package:flutter/material.dart';

class CircularNetworkImage extends StatelessWidget {
  final String? url;
  final double size;
  final BoxFit fit;
  final Widget? placeholder;

  const CircularNetworkImage({
    Key? key,
    required this.url,
    required this.size,
    this.fit = BoxFit.cover,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: placeholder ?? Icon(Icons.image_not_supported_outlined, size: size * 0.5, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: Icon(Icons.broken_image, size: size * 0.45, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
