class commoditymodel {
  int? id;
  String? commodityName;


  commoditymodel({this.id, this.commodityName});

  factory commoditymodel.fromJson(Map<String, dynamic> json) {
    return commoditymodel(
      id: json['id'],
      commodityName: json['commodityName'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commodityName': commodityName,

    };
  }
}