class Productsearchcriteria {

   int commodityid;

   String searchtext;

   Productsearchcriteria({
       required this.commodityid,
       required this.searchtext,
   });

Map<String, dynamic> toJson() {

     return {
       'commodityid': commodityid,
       'searchtext': searchtext,
     };
}
}