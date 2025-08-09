class Ingredient {
  final String name;
  final double ratio;
  final String unit;
  final double price;
  final double baseQuantity;

  Ingredient({
    required this.name,
    required this.ratio,
    required this.unit,
    required this.price,
    required this.baseQuantity,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ratio': ratio,
      'unit': unit,
      'price': price,
      'baseQuantity': baseQuantity,
    };
  }

  // Create from Map (from Firestore)
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      ratio: (map['ratio'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      baseQuantity: (map['baseQuantity'] ?? 0).toDouble(),
    );
  }

  // Copy with method
  Ingredient copyWith({
    String? name,
    double? ratio,
    String? unit,
    double? price,
    double? baseQuantity,
  }) {
    return Ingredient(
      name: name ?? this.name,
      ratio: ratio ?? this.ratio,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      baseQuantity: baseQuantity ?? this.baseQuantity,
    );
  }

  @override
  String toString() {
    return 'Ingredient(name: $name, ratio: $ratio, unit: $unit, price: $price, baseQuantity: $baseQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.name == name &&
        other.ratio == ratio &&
        other.unit == unit &&
        other.price == price &&
        other.baseQuantity == baseQuantity;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        ratio.hashCode ^
        unit.hashCode ^
        price.hashCode ^
        baseQuantity.hashCode;
  }
}

class Recipe {
  final String? id;
  final String title;
  final List<Ingredient> ingredients;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    this.id,
    required this.title,
    required this.ingredients,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ingredients': ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (from Firestore)
  factory Recipe.fromMap(Map<String, dynamic> map, String id) {
    return Recipe(
      id: id,
      title: map['title'] ?? '',
      ingredients: List<Ingredient>.from(
        (map['ingredients'] ?? []).map((x) => Ingredient.fromMap(x)),
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create new recipe
  factory Recipe.create({
    required String title,
    required List<Ingredient> ingredients,
  }) {
    final now = DateTime.now();
    return Recipe(
      title: title,
      ingredients: ingredients,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with method
  Recipe copyWith({
    String? id,
    String? title,
    List<Ingredient>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate total cost
  double get totalCost {
    return ingredients.fold(0.0, (sum, ingredient) {
      final costPerUnit = ingredient.price / ingredient.baseQuantity;
      final totalCost = costPerUnit * ingredient.ratio;
      return sum + totalCost;
    });
  }

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, ingredients: $ingredients, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.id == id &&
        other.title == title &&
        other.ingredients == ingredients;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ ingredients.hashCode;
  }
}
