class UserVote {
  final String name;
  final double vote;
  final String? icon;
  final String? color;
  final String username;
  final String userId;

  UserVote({
    required this.name,
    required this.vote,
    this.icon,
    this.color,
    required this.username,
    required this.userId,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory UserVote.fromMap(Map<String, dynamic> map) {
    return UserVote(
      name: map['category'],
      vote: map['vote'] != null ? double.parse('${map['vote']}') : 0,
      icon: map['icon'],
      color: map['color'],
      username: map['user_name'],
      userId: map['user_id'],
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'text': name,
      'vote': vote,
      'icon': icon,
      'color': color,
      'username': username,
      'user_id': userId,
    };
  }
}
