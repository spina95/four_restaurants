class Travel {
  final int id;
  final String name;
  final DateTime? from;
  final DateTime? to;

  Travel({
    required this.id,
    required this.name,
    this.from,
    this.to,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory Travel.fromMap(Map<String, dynamic> map) {
    return Travel(
      id: map['id'],
      name: map['name'],
      from: map['from'] != null ? DateTime.parse(map['from']) : null,
      to: map['to'] != null ? DateTime.parse(map['to']) : null,
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
    };
  }
}
