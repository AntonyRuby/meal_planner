import 'package:flutter/material.dart';
import 'package:meal_planner/recipe_screen.dart';

class MealPlanListView extends StatelessWidget {
  final String mealType;
  final List<Map<String, dynamic>> mealPlan;

  const MealPlanListView({Key? key, required this.mealType, required this.mealPlan})
      : super(key: key);

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
