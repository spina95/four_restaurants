import 'package:flutter/material.dart';
import 'package:four_restaurants/common.dart';
import 'package:four_restaurants/models/restaurant_category_model.dart';
import 'package:four_restaurants/models/restaurant_list_model.dart';
import 'package:four_restaurants/models/restaurant_votes_model.dart';
import 'package:four_restaurants/views/users_vote_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantDetailWidget extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailWidget({super.key, required this.restaurantId});

  @override
  _RestaurantDetailWidgetState createState() => _RestaurantDetailWidgetState();
}

class _RestaurantDetailWidgetState extends State<RestaurantDetailWidget> {
  final SupabaseClient supabase = Supabase.instance.client;
  RestaurantList? restaurant;
  bool isLoading = true;
  List<RestaurantVotes> averageVotes = [];
  List<RestaurantCategoryVote> categories = [];
  Map<String, double> votes = {};

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  bool areAllVotesFilled() {
    for (var category in categories) {
      if (category.userVote == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> fetchRestaurants() async {
    final response = await supabase.rpc(
        'get_restaurant_by_id_with_average_votes',
        params: {'restaurant_id': widget.restaurantId}).select();

    if (response.isNotEmpty) {
      restaurant =
          (response as List).map((e) => RestaurantList.fromMap(e)).toList()[0];
      if (restaurant!.open) {
        fetchCategories();
      } else {
        fetchRestaurantVotes();
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRestaurantVotes() async {
    final response = await supabase.rpc('get_average_votes_by_category',
        params: {'restaurant_id': restaurant!.id.toInt()}).select();

    if (response.isNotEmpty) {
      setState(() {
        averageVotes =
            (response as List).map((e) => RestaurantVotes.fromMap(e)).toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });
    final response =
        await supabase.rpc('get_categories_with_user_votes', params: {
      'restaurant_id': restaurant!.id.toInt(),
      'user_id': supabase.auth.currentUser!.id
    }).select();

    if (response.isNotEmpty) {
      setState(() {
        categories = (response as List)
            .map((e) => RestaurantCategoryVote.fromMap(e))
            .toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
        categories = [];
      });
    }
  }

  Future<void> submitVotes() async {
    try {
      for (RestaurantCategoryVote vote in categories) {
        if (vote.userVoteId == null) {
          await supabase.from('votes').insert({
            'restaurant': restaurant!.id,
            'category': vote.id,
            'vote': vote.userVote,
            'user': supabase.auth.currentUser!.id,
          });
        } else {
          await supabase.from('votes').update(
            {
              'vote': vote.userVote,
            },
          ).eq('id', vote.userVoteId!);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Voti inseriti con successo")),
      );
      Navigator.pop(context);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore nell'insermento del voto")),
      );
    }
  }

  Future<void> closeVoting() async {
    try {
      await supabase.from('restaurants').update({
        'open': false,
      }).eq('id', restaurant!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Votazioni chiuse con successo")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore nella chiusura delle votazioni")),
      );
    }
  }

  void showCloseVotingConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chiusura votazioni'),
          content: const Text('Sei sicuro di voler chiudere le votazioni?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                closeVoting();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant != null ? restaurant!.name.capitalize() : ""),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_pin),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            restaurant!.city,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            restaurant!.date != null
                                ? formatDateTime(restaurant!.date!)
                                : "",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!restaurant!.open)
                  Column(
                    children: [
                      Center(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: averageVotes.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: averageVotes[index].color != null
                                      ? hexToColor(averageVotes[index].color!)
                                      : Colors.black12,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(getMaterialIcon(
                                  averageVotes[index].icon,
                                )),
                              ),
                              title: Text(
                                averageVotes[index].name.capitalize(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              trailing: Text(
                                averageVotes[index].average.toString(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantVotesWidget(
                                    restaurant: restaurant!,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Tutti i voti"),
                          ),
                        ],
                      )
                    ],
                  )
                else
                  Column(
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          "Votazioni in corso",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var controller = TextEditingController();
                          controller.text = categories[index].userVote != null
                              ? categories[index].userVote.toString()
                              : "";
                          return ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: categories[index].color != null
                                    ? hexToColor(categories[index].color!)
                                    : Colors.black12,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(getMaterialIcon(
                                categories[index].icon,
                              )),
                            ),
                            title: Text(
                              categories[index].name.capitalize(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Voto',
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    categories[index].userVote =
                                        int.parse(value);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      FilledButton(
                        onPressed: areAllVotesFilled() ? submitVotes : null,
                        child: const Text('Invia voti'),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      FilledButton(
                        onPressed: showCloseVotingConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[300],
                        ),
                        child: const Text('Chiudi votazioni'),
                      ),
                    ],
                  )
              ],
            ),
    );
  }
}
