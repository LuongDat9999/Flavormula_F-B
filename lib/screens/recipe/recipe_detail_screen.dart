import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/number_formatter.dart';
import 'recipe_form_screen.dart';
import 'brewing_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _customUnitController = TextEditingController();
  int _quantity = 1; // Default 1 unit
  String _selectedUnit = 'suất'; // Default unit
  bool _showCustomUnitField = false;

  final List<String> _availableUnits = ['ly', 'lít', 'suất','kg' 'khác'];

  @override
  void initState() {
    super.initState();
    _quantityController.text = _quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  void _updateQuantity(String value) {
    setState(() {
      _quantity = int.tryParse(value) ?? 1;
      if (_quantity < 1) _quantity = 1;
    });
  }

  void _updateUnit(String? newUnit) {
    setState(() {
      _selectedUnit = newUnit ?? 'ly';
      _showCustomUnitField = _selectedUnit == 'khác';
      if (!_showCustomUnitField) {
        _customUnitController.clear();
      }
    });
  }

  // Get the current unit display text
  String get _currentUnitDisplay {
    if (_selectedUnit == 'khác' && _customUnitController.text.isNotEmpty) {
      return _customUnitController.text;
    }
    return _selectedUnit;
  }

  // Calculate ingredient quantity based on ratio and quantity
  double _calculateIngredientQuantity(Ingredient ingredient) {
    return ingredient.ratio * _quantity;
  }

  // Calculate ingredient cost based on quantity
  double _calculateIngredientCost(Ingredient ingredient) {
    final costPerUnit = ingredient.price / ingredient.baseQuantity;
    final totalQuantity = _calculateIngredientQuantity(ingredient);
    return costPerUnit * totalQuantity;
  }

  // Calculate total cost for all ingredients
  double _calculateTotalCost() {
    return widget.recipe.ingredients.fold(0.0, (sum, ingredient) {
      return sum + _calculateIngredientCost(ingredient);
    });
  }

  void _showDeleteDialog(BuildContext context) {
    final navigator = Navigator.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xóa công thức'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc chắn muốn xóa công thức "${widget.recipe.title}"?'),
              const SizedBox(height: 8),
              Text(
                'Hành động này không thể hoàn tác.',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                navigator.pop();
                await _deleteRecipe(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    
    if (authProvider.currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để xóa công thức'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading dialog
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Đang xóa công thức...'),
              ],
            ),
          );
        },
      );
    }

    try {
      final success = await recipeProvider.deleteRecipe(
        authProvider.currentUserId!,
        widget.recipe.id!,
      );
      
      if (!mounted) return;
      
      navigator.pop(); // Close loading dialog
      
      if (success) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Đã xóa công thức "${widget.recipe.title}" thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop(); // Go back to recipe list
      } else {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Lỗi xóa công thức. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop(); // Close loading dialog
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editRecipe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeFormScreen(recipe: widget.recipe),
      ),
    ).then((result) {
      // Refresh the screen if recipe was updated
      if (result == true) {
        setState(() {
          // Trigger rebuild to show updated data
        });
      }
    });
  }

  void _startBrewing(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrewingScreen(
          recipe: widget.recipe,
          quantity: _quantity,
          unit: _currentUnitDisplay,
        ),
      ),
    ).then((result) {
      // Show completion message if brewing was completed
      if (result == true && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('🎉 Chúc mừng! Bạn đã hoàn thành pha chế ${widget.recipe.title}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.recipe.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => _editRecipe(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Title and Quantity Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Unit Selection Dropdown
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Số lượng',
                              labelStyle: TextStyle(
                                color: Colors.blueGrey[600],
                                fontSize: 16,
                              ),
                              hintText: 'Nhập số lượng',
                              border: const OutlineInputBorder(),
                              fillColor: Colors.blueGrey[50],
                              prefixIcon: const Icon(Icons.local_drink),
                            ),
                            onChanged: _updateQuantity,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Đơn vị tính',
                              labelStyle: TextStyle(
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            items: _availableUnits.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: _updateUnit,
                          ),
                        ),
                      ],
                    ),
                    
                    // Custom Unit Field
                    if (_showCustomUnitField) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customUnitController,
                        decoration: const InputDecoration(
                          labelText: 'Nhập đơn vị tùy chỉnh',
                          hintText: 'Ví dụ: chai, bình, tách...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit),

                        ),
                        
                        
                        onChanged: (value) {
                          setState(() {
                            // Trigger rebuild to update display
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Ingredients Section
            Text(
              '${widget.recipe.ingredients.length} nguyên liệu',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryOrange,
                
              ),
              
            ),
            const SizedBox(height: 10),
            
            ...widget.recipe.ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              final calculatedQuantity = _calculateIngredientQuantity(ingredient);
              final calculatedCost = _calculateIngredientCost(ingredient);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ingredient.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                                                  Text(
                                    'Tỉ lệ: ${NumberFormatter.formatNumber(ingredient.ratio)} ${ingredient.unit}',
                                    style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(ingredient.price),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${NumberFormatter.formatNumber(ingredient.baseQuantity)} ${ingredient.unit}',
                                style: TextStyle(
                                  color: Colors.blueGrey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Calculated quantities for current quantity
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cho $_quantity $_currentUnitDisplay:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${NumberFormatter.formatNumber(calculatedQuantity)} ${ingredient.unit}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  _formatCurrency(calculatedCost),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            const SizedBox(height:10),
            
            // Total Summary
            Card(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng kết cho $_quantity $_currentUnitDisplay',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    
                    // Total cost
                      
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[600],
                          ),
                        ),
                        Text(
                          _formatCurrency(_calculateTotalCost()),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                          ),
                        ),
                    ],
                    ),
                    
                    const SizedBox(height: 8),
                    // Cost per unit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đơn $_currentUnitDisplay:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[600],
                          ),
                        ),
                        Text(
                          _formatCurrency(_calculateTotalCost() / _quantity),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Start Brewing Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startBrewing(context),
                icon: const Icon(Icons.local_drink, size: 24),
                label: const Text(
                  'Bắt đầu pha chế',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  String _formatCurrency(double amount) {
    return '${CurrencyFormatter.formatCurrency(amount)} VNĐ';
  }
}
