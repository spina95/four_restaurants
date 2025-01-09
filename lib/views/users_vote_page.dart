import 'package:flutter/material.dart';
import 'package:four_restaurants/common.dart';
import 'package:four_restaurants/models/restaurant_list_model.dart';
import 'package:four_restaurants/models/restaurant_votes_model.dart';
import 'package:four_restaurants/models/user_vote_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantVotesWidget extends StatefulWidget {
  final RestaurantList restaurant;

  const RestaurantVotesWidget({super.key, required this.restaurant});

  @override
  _RestaurantVotesWidgetState createState() => _RestaurantVotesWidgetState();
}

class _RestaurantVotesWidgetState extends State<RestaurantVotesWidget> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = true;
  List<UserVote> votes = [];

  @override
  void initState() {
    super.initState();
    fetchRestaurantVotes();
  }

  Future<void> fetchRestaurantVotes() async {
    final response = await supabase.rpc('get_average_votes_by_user',
        params: {'restaurant_id': widget.restaurant.id.toInt()}).select();

    if (response.isNotEmpty) {
      setState(() {
        votes = (response as List).map((e) => UserVote.fromMap(e)).toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  List<List<UserVote>> groupVotesByUser(List<UserVote> votes) {
    final Map<String, List<UserVote>> groupedVotes = {};

    for (var vote in votes) {
      if (!groupedVotes.containsKey(vote.userId)) {
        groupedVotes[vote.userId] = [];
      }
      groupedVotes[vote.userId]!.add(vote);
    }

    return groupedVotes.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupedVotes = groupVotesByUser(votes);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: groupedVotes.length,
                    itemBuilder: (context, index) {
                      final userVotes = groupedVotes[index];
                      return ExpansionTile(
                        title: Text(
                          userVotes.first.username,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        children: userVotes.map((vote) {
                          return ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: vote.color != null
                                    ? hexToColor(vote.color!)
                                    : Colors.black12,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(getMaterialIcon(
                                vote.icon,
                              )),
                            ),
                            title: Text(
                              vote.name.capitalize(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            trailing: Text(
                              vote.vote.toString(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
