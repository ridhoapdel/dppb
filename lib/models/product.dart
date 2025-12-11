class Product {
  final String id;
  final String name;
  final int price;
  final String desc;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int,
        desc: json['desc'] as String,
        images: List<String>.from(json['images'] as List),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'desc': desc,
        'images': images,
      };

  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? desc,
    List<String>? images,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      desc: desc ?? this.desc,
      images: images ?? this.images,
    );
  }
}
