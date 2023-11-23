import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  const RecipeDetailScreen({super.key, required this.meal});

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
                      color: Theme.of(context).primaryColor,
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
                      color: Theme.of(context).primaryColor,
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
