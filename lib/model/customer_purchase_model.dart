class CustomerPurchaseModel {
  final String purchaseItem;
  final double purchaseAmount;
  final String purchaseDate;
  final double weight;
  final String commodity;

  CustomerPurchaseModel({
    required this.purchaseItem,
    required this.purchaseAmount,
    required this.purchaseDate,
    required this.weight,
    required this.commodity,
  });

  // Factory method to create an instance from a JSON map
  factory CustomerPurchaseModel.fromJson(Map<String, dynamic> json) {
    return CustomerPurchaseModel(
      purchaseItem: json['purchaseItem'] as String,
      purchaseAmount: (json['purchaseAmount'] as num).toDouble(),
      purchaseDate: json['purchaseDate'] as String,
      weight: (json['weight'] as num).toDouble(),
      commodity: json['commodity'] as String,
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'purchaseItem': purchaseItem,
      'purchaseAmount': purchaseAmount,
      'purchaseDate': purchaseDate,
      'weight': weight,
      'commodity': commodity,
    };
  }
}
