class Bannerout {
    int? id;
    String? bannerImage;
    String? bannerHeaderText;
    String? bannerImageHeading;
    String? bannerImageBottom;

    Bannerout({this.id, this.bannerImage, this.bannerHeaderText, this.bannerImageHeading, this.bannerImageBottom});

    factory Bannerout.fromJson(Map<String, dynamic> json) {
        return Bannerout(
            id: json['id'],
            bannerImage: json['bannerImage'],
            bannerHeaderText: json['bannerHeaderText'],
            bannerImageHeading: json['bannerImageHeading'],
            bannerImageBottom: json['bannerImageBottom'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'bannerImage': bannerImage,
            'bannerHeaderText': bannerHeaderText,
            'bannerImageHeading': bannerImageHeading,
            'bannerImageBottom': bannerImageBottom,
        };
    }


}