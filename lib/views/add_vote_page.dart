import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage>
    with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  bool isLoading = false;
  List<TravelAdd> travels = [];
  TravelAdd? selectedTravel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    final response = await supabase.from('travels').select();

    if (response.isNotEmpty) {
      setState(() {
        travels = (response as List).map((e) => TravelAdd.fromMap(e)).toList();
      });
    }
  }

  Future<void> addRestaurant() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await supabase.from('restaurants').insert({
          'name': _nameController.text,
          'city': _cityController.text,
          'date': _dateController.text,
          'travel_id': selectedTravel?.id,
        });

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ristorante aggiunto con successo")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Errore: ${response.error!.message}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore nell'aggiunta del ristorante")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> addTravel() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await supabase.from('travels').insert({
          'name': _nameController.text,
          'from_date': _fromDateController.text,
          'to_date': _toDateController.text,
        });

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Viaggio aggiunto con successo")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Errore: ${response.error!.message}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore nell'aggiunta del viaggio")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aggiungi'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Ristorante'),
              Tab(text: 'Viaggio'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Per favore inserisci un nome';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'Città',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Per favore inserisci una città';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              labelText: 'Data',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Per favore inserisci una data';
                              }
                              return null;
                            },
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                _dateController.text =
                                    pickedDate.toString().split(' ')[0];
                              }
                            },
                          ),
                          DropdownButtonFormField<TravelAdd>(
                            value: selectedTravel,
                            decoration: const InputDecoration(
                              labelText: 'Viaggio',
                            ),
                            items: travels.map((TravelAdd travel) {
                              return DropdownMenuItem<TravelAdd>(
                                value: travel,
                                child: Text(travel.name),
                              );
                            }).toList(),
                            onChanged: (TravelAdd? newValue) {
                              setState(() {
                                selectedTravel = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Per favore seleziona un viaggio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: addRestaurant,
                              child: const Text('Aggiungi Ristorante'),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Per favore inserisci un nome';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _fromDateController,
                            decoration: const InputDecoration(
                              labelText: 'Data di inizio',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Per favore inserisci una data di inizio';
                              }
                              return null;
                            },
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                _fromDateController.text =
                                    pickedDate.toString().split(' ')[0];
                              }
                            },
                          ),
                          TextFormField(
                            controller: _toDateController,
                            decoration: const InputDecoration(
                              labelText: 'Data di fine',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Per favore inserisci una data di fine';
                              }
                              return null;
                            },
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                _toDateController.text =
                                    pickedDate.toString().split(' ')[0];
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: addTravel,
                              child: const Text('Aggiungi Viaggio'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class TravelAdd {
  final int id;
  final String name;

  TravelAdd({
    required this.id,
    required this.name,
  });

  factory TravelAdd.fromMap(Map<String, dynamic> map) {
    return TravelAdd(
      id: map['id'],
      name: map['name'],
    );
  }
}
