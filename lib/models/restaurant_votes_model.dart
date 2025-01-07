class RestaurantVotes {
  final String name;
  final double average;

  RestaurantVotes({
    required this.name,
    required this.average,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory RestaurantVotes.fromMap(Map<String, dynamic> map) {
    return RestaurantVotes(
      name: map['category'],
      average: map['average_votes'] ?? 0,
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'text': name,
      'average_votes': average,
    };
  }
}
