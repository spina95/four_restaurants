class Restaurant {
  final int id;
  final String name;
  final String city;
  final DateTime date;

  Restaurant({
    required this.id,
    required this.name,
    required this.city,
    required this.date,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      date: DateTime.parse(map['date']),
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'date': date.toIso8601String(),
    };
  }
}
