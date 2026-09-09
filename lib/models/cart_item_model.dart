/// Ҷузъи сабад (banди 11 спецификатсия). Cart дар ин лоиҳа **local-only**
/// аст (device storage, на Firestore) — қарори тарроҳӣ, зеро сабад
/// муваққатист ва то checkout шудан "ҳолати доимӣ" лозим надорад; ин
/// ҳам costи Firestore write-ро кам мекунад (banди 25 — free tier).
/// Пас аз checkout, cart ба `Order` табдил меёбад (ки он дар Firestore аст).
class CartItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final String sellerId;
  final String? businessId;
  final int availableQuantity;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.sellerId,
    this.businessId,
    required this.availableQuantity,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'price': price,
        'sellerId': sellerId,
        'businessId': businessId,
        'availableQuantity': availableQuantity,
        'quantity': quantity,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        productImage: map['productImage'] as String,
        price: (map['price'] as num).toDouble(),
        sellerId: map['sellerId'] as String,
        businessId: map['businessId'] as String?,
        availableQuantity: map['availableQuantity'] as int? ?? 0,
        quantity: map['quantity'] as int? ?? 1,
      );
}
