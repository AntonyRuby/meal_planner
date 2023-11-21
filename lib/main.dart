import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ThemeData().colorScheme.copyWith(secondary: Colors.green),
        fontFamily: 'Montserrat', // Example of a different font
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
  late List<Map<String, dynamic>> mealPlan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    mealPlan = [];
    loadMealPlan();
  }

  Future<void> loadMealPlan() async {
    // Load the JSON file
    String jsonString = await rootBundle.loadString('assets/meal_plan.json');

    // Parse the JSON
    setState(() {
      mealPlan = List<Map<String, dynamic>>.from(json.decode(jsonString));
    });
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (var mealType in ['Breakfast', 'Lunch', 'Snack', 'Dinner'])
            MealPlanListView(
              mealPlan: mealPlan,
              mealType: mealType,
            ),
        ],
      ),
    );
  }
}

class MealPlanListView extends StatelessWidget {
  final String mealType;
  final List<Map<String, dynamic>> mealPlan;

  const MealPlanListView({
    Key? key,
    required this.mealType,
    required this.mealPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mealPlan.length,
      itemBuilder: (context, index) {
        final day = mealPlan[index]['day'];
        final mealsForDay = mealPlan[index]['meals'][mealType];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(mealsForDay['Name']),
            subtitle: Text(day),
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

void main() {
  runApp(const MyApp());
}
