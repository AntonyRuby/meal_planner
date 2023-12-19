import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ThemeData().colorScheme.copyWith(secondary: Colors.green),
        fontFamily: 'Montserrat', // Example of a different font
        textTheme: TextTheme(
          headline6:
              const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> mealPlan = [];
  late Future<List<Map<String, dynamic>>> mealPlanFuture;

  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    mealPlan = [];
    mealPlanFuture = loadMealPlan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> loadMealPlan() async {
    try {
      String jsonString = await rootBundle.loadString('assets/meal_plan.json');
      print(jsonString);
      return List<Map<String, dynamic>>.from(json.decode(jsonString));
    } catch (error) {
      print('Error loading meal plan: $error');
      return []; // Return an empty list or handle the error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Snacks'),
            Tab(text: 'Dinner'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: showFavoritesOnly ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                showFavoritesOnly = !showFavoritesOnly;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: mealPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading meal plan'),
            );
          } else if (snapshot.hasData) {
            mealPlan = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                for (var mealType in ['Breakfast', 'Lunch', 'Snack', 'Dinner'])
                  MealPlanListView(
                    mealPlan: mealPlan,
                    mealType: mealType,
                    showFavoritesOnly: showFavoritesOnly,
                    onFavoriteChanged: (index, mealType) {
                      // Callback to handle favorite changes
                      _saveFavorite(index, mealType);
                    },
                  ),
              ],
            );
          } else {
            return const Center(
              child: Text('No data found'),
            );
          }
        },
      ),
    );
  }

  // Save the updated mealPlan to SharedPreferences
  Future<void> _saveFavorite(int index, String mealType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final meal = mealPlan[index]['meals'][mealType];
    prefs.setBool('${meal['Name']}_$mealType', meal['favorite'] ?? false);
  }
}

class MealPlanListView extends StatefulWidget {
  final String mealType;
  final List<Map<String, dynamic>> mealPlan;
  final bool showFavoritesOnly;
  final Function(int, String) onFavoriteChanged;

  const MealPlanListView({
    Key? key,
    required this.mealType,
    required this.mealPlan,
    required this.showFavoritesOnly,
    required this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<MealPlanListView> createState() => _MealPlanListViewState();
}

class _MealPlanListViewState extends State<MealPlanListView> {
  @override
  Widget build(BuildContext context) {
    final filteredMealPlan = widget.showFavoritesOnly
        ? widget.mealPlan
            .where((day) =>
                day['meals'][widget.mealType]['favorite'] != null &&
                day['meals'][widget.mealType]['favorite'] == true)
            .toList()
        : widget.mealPlan;

    return filteredMealPlan.isEmpty
        ? _buildLoadingIndicator()
        : _buildFavoriteList(context, filteredMealPlan);
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFavoriteList(
      BuildContext context, List<Map<String, dynamic>> favorites) {
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final day = favorites[index]['day'];
        final mealsForDay = favorites[index]['meals'][widget.mealType];
        final isFavorite = mealsForDay['favorite'] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 3,
          child: ListTile(
            title: Text(mealsForDay['Name']),
            subtitle: Text(day),
            trailing: IconButton(
              icon: isFavorite
                  ? Icon(Icons.favorite, color: Colors.red)
                  : Icon(Icons.favorite_border),
              onPressed: () {
                _toggleFavorite(index, widget.mealType);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(
                    meal: mealsForDay,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Function to toggle the favorite status
  Future<void> _toggleFavorite(int index, String mealType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      final meal = widget.mealPlan[index]['meals'][mealType];
      meal['favorite'] =
          !(meal['favorite'] ?? false); // Toggle the favorite status
    });

    // Save the updated mealPlan to persistent storage
    prefs.setBool(
        '${widget.mealPlan[index]['meals'][mealType]['Name']}_$mealType',
        widget.mealPlan[index]['meals'][mealType]['favorite'] ?? false);
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  RecipeDetailScreen({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['Name']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (meal['Recipe'] != null) ...[
              for (var recipeKey in meal['Recipe'].keys)
                if (meal['Recipe'][recipeKey]['Ingredients'] != null) ...[
                  Text(
                    '$recipeKey:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  for (var ingredient in meal['Recipe'][recipeKey]
                      ['Ingredients'])
                    Text('• $ingredient'),
                  const SizedBox(height: 8),
                ],
            ],
            const SizedBox(height: 16),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (meal['Recipe'] != null) ...[
              for (var recipeKey in meal['Recipe'].keys)
                if (meal['Recipe'][recipeKey]['Instructions'] != null) ...[
                  Text(
                    '$recipeKey:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  for (var step in meal['Recipe'][recipeKey]['Instructions'])
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          '${meal['Recipe'][recipeKey]['Instructions'].indexOf(step) + 1}',
                        ),
                      ),
                      title: Text(step),
                    ),
                  const SizedBox(height: 8),
                ],
            ],
            const SizedBox(height: 16),
            const Text(
              'Nutrients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (meal['Nutrients'] != null) ...[
              for (var nutrient in meal['Nutrients'].keys)
                Text(
                  '$nutrient: ${meal['Nutrients'][nutrient]['value']} ${meal['Nutrients'][nutrient]['unit']}',
                ),
            ],
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}
