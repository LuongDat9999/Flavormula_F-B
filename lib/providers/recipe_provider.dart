import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load recipes for a user
  Future<void> loadRecipes(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      _recipeService.getRecipes(userId).listen((recipes) {
        _recipes = recipes;
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError('Lỗi tải danh sách công thức: $e');
    }
  }

  // Create a new recipe
  Future<bool> createRecipe(String userId, Recipe recipe) async {
    try {
      _setLoading(true);
      _clearError();
      
      final recipeId = await _recipeService.createRecipe(userId, recipe);
      
      _setLoading(false);
      return recipeId != null;
    } catch (e) {
      _setError('Lỗi tạo công thức: $e');
      return false;
    }
  }

  // Update a recipe
  Future<bool> updateRecipe(String userId, String recipeId, Recipe recipe) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _recipeService.updateRecipe(userId, recipeId, recipe);
      
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Lỗi cập nhật công thức: $e');
      return false;
    }
  }

  // Delete a recipe
  Future<bool> deleteRecipe(String userId, String recipeId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _recipeService.deleteRecipe(userId, recipeId);
      
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Lỗi xóa công thức: $e');
      return false;
    }
  }

  // Search recipes
  Future<void> searchRecipes(String userId, String query) async {
    try {
      _setLoading(true);
      _clearError();
      
      _recipeService.searchRecipes(userId, query).listen((recipes) {
        _recipes = recipes;
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError('Lỗi tìm kiếm công thức: $e');
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  // Clear recipes
  void clearRecipes() {
    _recipes = [];
    notifyListeners();
  }
}
