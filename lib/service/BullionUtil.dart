class BullionUtil{

  static String  readString(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '-';
  }

  static String readImageUrl(Map<String, dynamic> item) {
    final imagePathValue = item['imagepath'];
    if (imagePathValue is List) {
      for (final raw in imagePathValue) {
        final candidate = raw?.toString().trim() ?? '';
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
    } else if (imagePathValue is String && imagePathValue.trim().isNotEmpty) {
      return imagePathValue.trim();
    }

    final directUrl = BullionUtil.readString(item, [
      'imageUrl',
      'imagename',
      'image',
      'url',
    ]);
    if (directUrl != '-' && directUrl.trim().isNotEmpty) {
      return directUrl;
    }

    final imageMap =
        item['subcatimages'] ?? item['catimages'] ?? item['images'];
    if (imageMap is Map) {
      final map = Map<String, dynamic>.from(imageMap);

      final nestedImagePath = map['imagepath'];
      if (nestedImagePath is List) {
        for (final raw in nestedImagePath) {
          final candidate = raw?.toString().trim() ?? '';
          if (candidate.isNotEmpty) {
            return candidate;
          }
        }
      } else if (nestedImagePath is String &&
          nestedImagePath.trim().isNotEmpty) {
        return nestedImagePath.trim();
      }

      final mappedUrl = BullionUtil.readString(map, [
        'url',
        'imageUrl',
        'path',
        'filename',
      ]);
      if (mappedUrl != '-' && mappedUrl.trim().isNotEmpty) {
        return mappedUrl;
      }
    }

    return '';
  }

  static double readDouble(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value == null) continue;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return 0;
  }

}