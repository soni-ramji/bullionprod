import 'package:bullionprod/service/BullionUtil.dart';

class CommodityRateModel {

   int? id;
   double? goldsell;
   double? silversell;
   double? goldpurchase;
   double? silverpurchase;

   CommodityRateModel({this.id,this.goldsell,this.silversell ,this.goldpurchase,this.silverpurchase});

   factory CommodityRateModel.fromJson(Map<String, dynamic> json) {
     return CommodityRateModel(
       id: json['id'],
       goldsell:  BullionUtil.readDouble(json,'goldsell'),
       silversell:  BullionUtil.readDouble(json,'silversell'),
       goldpurchase:  BullionUtil.readDouble(json,'goldpurchase'),
       silverpurchase:  BullionUtil.readDouble(json,'silverpurchase'),

     );
   }

   Map<String, dynamic> toJson() {
     return {
       'id': id,
       'goldsell': goldsell,
       'silversell': silversell,
       'goldpurchase': goldpurchase,
       'silverpurchase': silverpurchase,

     };
   }
}