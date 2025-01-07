class RestaurantCategoryVote {
  final int id;
  final String name;
  int? userVote;
  final int? userVoteId;

  RestaurantCategoryVote({
    required this.id,
    required this.name,
    this.userVote,
    this.userVoteId,
  });

  // Metodo per creare un'istanza di Restaurant da una mappa (ad esempio, dai dati di Supabase)
  factory RestaurantCategoryVote.fromMap(Map<String, dynamic> map) {
    return RestaurantCategoryVote(
      id: map['category_id'],
      name: map['category_name'],
      userVote: map['user_vote'],
      userVoteId: map['user_vote_id'],
    );
  }

  // Metodo per convertire un'istanza di Restaurant in una mappa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user_vote': userVote,
      'user_vote_id': userVoteId,
    };
  }
}
