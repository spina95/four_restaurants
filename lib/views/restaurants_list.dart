import 'package:flutter/material.dart';
import 'package:four_restaurants/models/restaurant_list_model.dart';
import 'package:four_restaurants/views/addVotePage.dart';
import 'package:four_restaurants/views/restaurant_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantsListWidget extends StatefulWidget {
  const RestaurantsListWidget({super.key});

  @override
  _RestaurantsListWidgetState createState() => _RestaurantsListWidgetState();
}

class _RestaurantsListWidgetState extends State<RestaurantsListWidget> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<RestaurantList> restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final response =
        await supabase.rpc('get_restaurants_with_average_votes').select();

    if (response.isNotEmpty) {
      setState(() {
        restaurants =
            (response as List).map((e) => RestaurantList.fromMap(e)).toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista dei Ristoranti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVotePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: restaurants.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(restaurants[index].name),
                  subtitle: Text(restaurants[index].city),
                  trailing: Text(
                    restaurants[index].averageVotes.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailWidget(
                          restaurant: restaurants[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
