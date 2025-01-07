class RestaurantList {
  final int id;
  final String name;
  final String city;
  final DateTime date;
  final double averageVotes;

  RestaurantList({
    required this.id,
    required this.name,
    required this.city,
    required this.date,
    required this.averageVotes,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory RestaurantList.fromMap(Map<String, dynamic> map) {
    return RestaurantList(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      date: DateTime.parse(map['date']),
      averageVotes: map['average_votes'] ?? 0,
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'date': date.toIso8601String(),
      'average_votes': averageVotes,
    };
  }
}
