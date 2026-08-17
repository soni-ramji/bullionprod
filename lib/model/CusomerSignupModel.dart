class CustomerSignup {
  int? id;
  String? name;
  String? tradename;
  String? type;
  String? mobileno;
  String? typename;
  String? address;
  String? identitytype;
  String? identityvalue;
  String? passwd;

  CustomerSignup({this.id, this.name, this.tradename, this.type, this.mobileno, this.typename, this.address, this.identitytype, this.identityvalue, this.passwd});

  factory CustomerSignup.fromJson(Map<String, dynamic> json) {
    return CustomerSignup(
      id: json['id'],
      name: json['name'],
      tradename: json['tradename'],
      type: json['type'],
      mobileno: json['mobileno'],
      typename: json['typename'],
      address: json['address'],
      identitytype: json['identitytype'],
      identityvalue: json['identityvalue'],
      passwd: json['passwd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tradename': tradename,
      'type': type,
      'mobileno': mobileno,
      'typename': typename,
      'address': address,
      'identitytype': identitytype,
      'identityvalue': identityvalue,
      'passwd': passwd,
    };
  }
}