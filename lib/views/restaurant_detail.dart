import 'package:flutter/material.dart';
import 'package:four_restaurants/common.dart';
import 'package:four_restaurants/models/restaurant_list_model.dart';
import 'package:four_restaurants/models/restaurant_votes_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantDetailWidget extends StatefulWidget {
  final RestaurantList restaurant;

  const RestaurantDetailWidget({super.key, required this.restaurant});

  @override
  _RestaurantDetailWidgetState createState() => _RestaurantDetailWidgetState();
}

class _RestaurantDetailWidgetState extends State<RestaurantDetailWidget> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = true;
  List<RestaurantVotes> averageVotes = [];

  @override
  void initState() {
    super.initState();
    fetchRestaurantVotes();
  }

  Future<void> fetchRestaurantVotes() async {
    final response = await supabase.rpc('get_average_votes_by_category',
        params: {'restaurant_id': widget.restaurant.id.toInt()}).select();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
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
                      Text("Città: ${widget.restaurant.city}"),
                      Text("Data:${formatDateTime(widget.restaurant.date)}"),
                    ],
                  ),
                ),
                Center(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: averageVotes.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(averageVotes[index].name),
                        trailing: Text(
                          averageVotes[index].average.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
