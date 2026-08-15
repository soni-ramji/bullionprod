class CategoryModel {
  int? id;

  String? catname;

  bool? isactive;

  int? commodityId;

  String? commodityName;

  String? description;

  Map<String, String>? catimages;

  String? imagename;

  String? imageurl;

  CategoryModel({
    this.id,
    this.catname,
    this.isactive,
    this.commodityId,
    this.commodityName,
    this.description,
    this.catimages,
    this.imagename,
    this.imageurl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      catname: json['catname'],
      isactive: json['isactive'],
      commodityId: json['commodityId'],
      commodityName: json['commodityName'],
      description: json['description'],
      catimages: json['catimages'] != null
          ? Map<String, String>.from(json['catimages'])
          : null,
      imagename: json['imagename'],
      imageurl: json['imageurl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catname': catname,
      'isactive': isactive,
      'commodityId': commodityId,
      'commodityName': commodityName,
      'description': description,
      'catimages': catimages,
      'imagename': imagename,
      'imageurl': imageurl,
    };
  }
}
