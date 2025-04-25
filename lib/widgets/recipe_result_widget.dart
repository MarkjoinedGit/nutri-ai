import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RecipeResultWidget extends StatelessWidget {
  final String recipeResult;

  const RecipeResultWidget({super.key, required this.recipeResult});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Suggestion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            MarkdownBody(
              data: recipeResult,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                p: const TextStyle(fontSize: 14),
                listBullet: const TextStyle(fontSize: 14),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                blockSpacing: 12,
                listIndent: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}