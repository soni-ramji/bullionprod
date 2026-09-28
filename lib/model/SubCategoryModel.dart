import 'package:bullionprod/service/BullionUtil.dart';

class SubCategoryModel {
  int id;
  int catid;
  String subcatname;
  String description;
  bool isactive;
  bool isformobile;

  String subcatimages;


  SubCategoryModel({
    required this.id,
    required this.catid,
    required this.subcatname,
    required this.description,
    required this.isactive,
    required this.isformobile,
    required this.subcatimages,

  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catid': catid,
      'subcatname': subcatname,
      'description': description,
      'isactive': isactive,
      'isformobile': isformobile,
      'subcatimages': subcatimages,

    };
  }

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: BullionUtil.readInt(json, 'id'),
      catid: BullionUtil.readInt(json, 'catid'),
      subcatname: (json['subcatname']?.toString() ?? ''),
      description: (json['description']?.toString() ?? ''),

      isactive: BullionUtil.readBool(json, 'isactive'),
      isformobile: BullionUtil.readBool(json, ' isformobile'),

      // subcatimages: BullionUtil.readListStringValue(json, 'subcatimages'),
      subcatimages: (json['subcatimages']?.toString() ?? '' ),

    );
  }
}