import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recipes for a user
  Stream<List<Recipe>> getRecipes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get a single recipe
  Future<Recipe?> getRecipe(String userId, String recipeId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId)
          .get();

      if (doc.exists) {
        return Recipe.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting recipe: $e');
      return null;
    }
  }

  // Create a new recipe
  Future<String?> createRecipe(String userId, Recipe recipe) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .add(recipe.toMap());

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating recipe: $e');
      return null;
    }
  }

  // Update a recipe
  Future<bool> updateRecipe(String userId, String recipeId, Recipe recipe) async {
    try {
      final updatedRecipe = recipe.copyWith(
        id: recipeId,
        createdAt: recipe.createdAt, // Keep original creation date
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId)
          .update(updatedRecipe.toMap());

      return true;
    } catch (e) {
      debugPrint('Error updating recipe: $e');
      return false;
    }
  }

  // Delete a recipe
  Future<bool> deleteRecipe(String userId, String recipeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Error deleting recipe: $e');
      return false;
    }
  }

  // Search recipes by title
  Stream<List<Recipe>> searchRecipes(String userId, String query) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '$query\uf8ff')
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
