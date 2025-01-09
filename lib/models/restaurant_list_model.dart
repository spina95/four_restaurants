class RestaurantList {
  final int id;
  final String name;
  final String city;
  final DateTime? date;
  final double averageVotes;
  final int? userCount;
  final bool open;

  RestaurantList({
    required this.id,
    required this.name,
    required this.city,
    this.date,
    required this.averageVotes,
    this.userCount,
    required this.open,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory RestaurantList.fromMap(Map<String, dynamic> map) {
    return RestaurantList(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      averageVotes: map['average_votes'] ?? 0,
      userCount: map['user_count'] ?? 0,
      open: map['open'],
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'date': date?.toIso8601String(),
      'average_votes': averageVotes,
      'user_count': userCount,
      'open': open,
    };
  }
}
