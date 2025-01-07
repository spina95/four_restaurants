import 'package:flutter/material.dart';
import 'package:four_restaurants/models/restaurant_category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';

class AddVotePage extends StatefulWidget {
  const AddVotePage({super.key});

  @override
  _AddVotePageState createState() => _AddVotePageState();
}

class _AddVotePageState extends State<AddVotePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Restaurant> restaurants = [];
  List<RestaurantCategoryVote> categories = [];
  Restaurant? selectedRestaurant;
  Map<String, double> votes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final response = await supabase.from('restaurants').select();
    if (response.isNotEmpty) {
      setState(() {
        restaurants =
            (response as List).map((e) => Restaurant.fromMap(e)).toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories(Restaurant restaurant) async {
    setState(() {
      isLoading = true;
    });
    final response =
        await supabase.rpc('get_categories_with_user_votes', params: {
      'restaurant_id': selectedRestaurant!.id.toInt(),
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
            'restaurant': selectedRestaurant!.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Voti'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownButton<Restaurant>(
                    hint: const Text('Seleziona un ristorante'),
                    value: selectedRestaurant,
                    onChanged: (Restaurant? newValue) {
                      setState(() {
                        selectedRestaurant = newValue;
                      });
                      fetchCategories(newValue!);
                    },
                    items: restaurants.map((Restaurant restaurant) {
                      return DropdownMenuItem<Restaurant>(
                        value: restaurant,
                        child: Text(restaurant.name),
                      );
                    }).toList(),
                  ),
                  if (selectedRestaurant != null && categories.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        var controller = TextEditingController();
                        controller.text = categories[index].userVote != null
                            ? categories[index].userVote.toString()
                            : "";
                        return ListTile(
                          title: Text(categories[index].name),
                          trailing: SizedBox(
                            width: 100,
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Voto',
                              ),
                              onChanged: (value) {
                                categories[index].userVote = int.parse(value);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ElevatedButton(
                    onPressed: submitVotes,
                    child: const Text('Invia Voti'),
                  ),
                ],
              ),
            ),
    );
  }
}
