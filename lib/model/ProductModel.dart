import 'package:bullionprod/service/BullionUtil.dart';

class ProductModel {
  int id;
  int subcatid;
  String prodname;
  double prodweight;
  double prodpurity;
  double karatpurity;
  String stamp;
  double wastage;
  double labourpergm;
  double margin;
  double returnpurity;
  bool ishallmark;
  bool ishuid;
  String huidno;
  String owner;
  List<String> imagepath;
  String searchtext;
  double productprice;

  ProductModel({
    required this.id,
    required this.subcatid,
    required this.prodname,
    required this.prodweight,
    required this.prodpurity,
    required this.karatpurity,
    required this.stamp,
    required this.wastage,
    required this.labourpergm,
    required this.margin,
    required this.returnpurity,
    required this.ishallmark,
    required this.ishuid,
    required this.huidno,
    required this.owner,
    required this.imagepath,
    required this.searchtext,
    required this.productprice,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcatid': subcatid,
      'prodname': prodname,
      'prodweight': prodweight,
      'prodpurity': prodpurity,
      'karatpurity': karatpurity,
      'stamp': stamp,
      'wastage': wastage,
      'labourpergm': labourpergm,
      'margin': margin,
      'returnpurity': returnpurity,
      'ishallmark': ishallmark,
      'ishuid': ishuid,
      'huidno': huidno,
      'owner': owner,
      'imagepath': imagepath,
      'searchtext': searchtext,
      'productprice': productprice,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: BullionUtil.readInt(json, 'id'),

      prodname: (json['prodname']?.toString() ?? ''),
      prodweight: BullionUtil.readDouble(json, 'prodweight'),
      prodpurity: BullionUtil.readDouble(json, 'prodpurity'),
      karatpurity: BullionUtil.readDouble(json, 'karatpurity'),
      stamp: (json['stamp']?.toString() ?? ''),
      wastage: BullionUtil.readDouble(json, 'wastage'),
      labourpergm: BullionUtil.readDouble(json, 'labourpergm'),
      margin: BullionUtil.readDouble(json, 'margin'),
      returnpurity: BullionUtil.readDouble(json, 'returnpurity'),
      ishallmark: BullionUtil.readBool(json, 'ishallmark'),
      ishuid: BullionUtil.readBool(json, 'ishuid'),
      huidno: (json['huidno']?.toString() ?? ''),
      owner: (json['owner']?.toString() ?? ''),
      imagepath: BullionUtil.readListStringValue(json, 'imagepath'),
      searchtext: (json['searchtext']?.toString() ?? ''),
      productprice: BullionUtil.readDouble(json, 'productprice'),
      subcatid: BullionUtil.readInt(json, 'subcatid'),
    );
  }
}
