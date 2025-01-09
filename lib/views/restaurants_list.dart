import 'package:flutter/material.dart';
import 'package:four_restaurants/common.dart';
import 'package:four_restaurants/models/restaurant_list_model.dart';
import 'package:four_restaurants/models/travel_model.dart';
import 'package:four_restaurants/views/add_vote_page.dart';
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
  List<Travel> travels = [];

  bool isLoading = true;
  bool rankMode = false;

  @override
  void initState() {
    super.initState();
    rankMode ? fetchRestaurants() : fetchTravels();
  }

  Future<void> fetchTravels() async {
    final response = await supabase.from('travels').select();

    if (response.isNotEmpty) {
      setState(() {
        travels = (response as List).map((e) => Travel.fromMap(e)).toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRestaurants() async {
    setState(() {
      isLoading = true;
    });
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
        title: Text(rankMode ? 'Ristoranti' : 'Viaggi'),
        leading: IconButton(
            icon: Icon(rankMode
                ? Icons.format_list_numbered_rounded
                : Icons.travel_explore_rounded),
            onPressed: () {
              setState(() {
                rankMode = !rankMode;
              });
              if (!rankMode) {
                fetchTravels();
              } else {
                fetchRestaurants();
              }
            }),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddItemPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: rankMode ? fetchRestaurants : fetchTravels,
              child: ListView.separated(
                itemCount: rankMode ? restaurants.length : travels.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return rankMode
                      ? ListTile(
                          minTileHeight: 80,
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurants[index].name.capitalize(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                restaurants[index].city,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: restaurants[index].open ? 100 : 48,
                            child: !restaurants[index].open
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        restaurants[index]
                                            .averageVotes
                                            .toStringAsPrecision(3),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            restaurants[index]
                                                .userCount
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.people_rounded),
                                        ],
                                      )
                                    ],
                                  )
                                : Chip(
                                    label: const Text("In corso"),
                                    backgroundColor: Colors.green,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      side: const BorderSide(
                                          color: Colors.transparent),
                                    ),
                                  ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailWidget(
                                  restaurantId: restaurants[index].id,
                                ),
                              ),
                            );
                          },
                        )
                      : ListTile(
                          minTileHeight: 80,
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                travels[index].name.capitalize(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                travels[index].from != null &&
                                        travels[index].to != null
                                    ? 'Dal ${travels[index].from!.day}/${travels[index].from!.month}/${travels[index].from!.year}'
                                        ' al ${travels[index].to!.day}/${travels[index].to!.month}/${travels[index].to!.year}'
                                    : '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailWidget(
                                  restaurantId: travels[index].id,
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
    );
  }
}
