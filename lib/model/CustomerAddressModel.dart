class Customeraddressmodel {

  int? id;
  String? locality;
  String? tehsil;
  String? city;
  String? state;
  String? district;
  String? addresstype;
  String? pin;
  String? mobile;
  int? custid;

  Customeraddressmodel(
      {this.id, this.locality, this.tehsil, this.city, this.state, this.district, this.addresstype, this.pin, this.mobile, this.custid});

  factory Customeraddressmodel.fromJson(Map<String, dynamic> json) {
    return Customeraddressmodel(
      id: json['id'],
      locality: json['locality'],
      tehsil: json['tehsil'],
      city: json['city'],
      state: json['state'],
      district: json['district'],
      addresstype: json['addresstype'],
      pin: json['pin'],
      mobile: json['mobile'],
      custid: json['custid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locality': locality,
      'tehsil': tehsil,
      'city': city,
      'state': state,
      'district': district,
      'addresstype': addresstype,
      'pin': pin,
      'mobile': mobile,
      'custid': custid,
    };
  }
}