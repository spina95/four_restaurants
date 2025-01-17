class RestaurantVotes {
  final String name;
  final double average;
  final String? icon;
  final String? color;

  RestaurantVotes({
    required this.name,
    required this.average,
    this.icon,
    this.color,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory RestaurantVotes.fromMap(Map<String, dynamic> map) {
    return RestaurantVotes(
      name: map['category'],
      average: map['average_votes'] ?? 0,
      icon: map['icon'],
      color: map['color'],
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'text': name,
      'average_votes': average,
      'icon': icon,
      'color': color,
    };
  }
}
