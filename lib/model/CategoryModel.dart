class CategoryModel {
  int? id;
  String? catname;
  bool? isactive;
  int? commodityId;
  String? commodityName;
  String? description;
  String? imagepath;
  String? imagename;
  String? imageurl;

  CategoryModel({
    this.id,
    this.catname,
    this.isactive,
    this.commodityId,
    this.commodityName,
    this.description,
    this.imagepath,
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
      imagepath: json['imagepath'],
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
      'imagepath': imagepath,
      'imagename': imagename,
      'imageurl': imageurl,
    };
  }
}
