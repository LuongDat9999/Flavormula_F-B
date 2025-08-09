import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../constants/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/number_formatter.dart';

class BrewingScreen extends StatefulWidget {
  final Recipe recipe;
  final int quantity;
  final String unit;

  const BrewingScreen({
    super.key,
    required this.recipe,
    required this.quantity,
    required this.unit,
  });

  @override
  State<BrewingScreen> createState() => _BrewingScreenState();
}

class _BrewingScreenState extends State<BrewingScreen> {
  Map<int, bool> ingredientDone = {};
  double doneTotalGram = 0.0;
  double doneTotalML = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize all ingredients as not done
    for (int i = 0; i < widget.recipe.ingredients.length; i++) {
      ingredientDone[i] = false;
    }
    _updateTotals();
  }

  // Calculate ingredient quantity based on ratio and quantity
  double _calculateIngredientQuantity(Ingredient ingredient) {
    return ingredient.ratio * widget.quantity;
  }

  // Calculate total cost for all ingredients
  double _calculateTotalCost() {
    return widget.recipe.ingredients.fold(0.0, (sum, ingredient) {
      final costPerUnit = ingredient.price / ingredient.baseQuantity;
      final totalQuantity = _calculateIngredientQuantity(ingredient);
      return sum + (costPerUnit * totalQuantity);
    });
  }

  void _updateTotals() {
    setState(() {
      doneTotalGram = 0.0;
      doneTotalML = 0.0;
      
      for (int i = 0; i < widget.recipe.ingredients.length; i++) {
        if (ingredientDone[i] == true) {
          final ingredient = widget.recipe.ingredients[i];
          final total = _calculateIngredientQuantity(ingredient);
          
          if (ingredient.unit == 'g') {
            doneTotalGram += total;
          } else if (ingredient.unit == 'ml') {
            doneTotalML += total;
          }
        }
      }
    });
  }

  void _toggleIngredient(int index) {
    final ingredient = widget.recipe.ingredients[index];
    final isCurrentlyDone = ingredientDone[index] ?? false;
    
    if (isCurrentlyDone) {
      // If already done, ask for confirmation to undo
      _showUndoDialog(index, ingredient.name);
    } else {
      // If not done, ask for confirmation to mark as done
      _showConfirmDialog(index, ingredient.name);
    }
  }

  void _showConfirmDialog(int index, String ingredientName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn đã chắc chắn đã cân xong $ingredientName chưa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chưa'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  ingredientDone[index] = true;
                });
                _updateTotals();
              },
              child: const Text('Đã xong'),
            ),
          ],
        );
      },
    );
  }

  void _showUndoDialog(int index, String ingredientName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn muốn đánh dấu lại chưa cân xong $ingredientName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  ingredientDone[index] = false;
                });
                _updateTotals();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đánh dấu lại'),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận hoàn tất'),
          content: const Text('Bạn đã hoàn tất pha chế món này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chưa'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // Return true to indicate completion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hoàn tất'),
            ),
          ],
        );
      },
    );
  }

  bool get _allIngredientsDone {
    return ingredientDone.values.every((done) => done == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.recipe.title} cho ${widget.quantity} ${widget.unit}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingredients List
            ...widget.recipe.ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              final calculatedQuantity = _calculateIngredientQuantity(ingredient);
              final isDone = ingredientDone[index] ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isDone ? Colors.green.withValues(alpha: 0.1) : Colors.white,
                child: InkWell(
                  onTap: () => _toggleIngredient(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Checkbox
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDone ? Colors.green : Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDone ? Colors.green : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Ingredient Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDone ? Colors.green[700] : Colors.black,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${NumberFormatter.formatNumber(calculatedQuantity)} ${ingredient.unit}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDone ? Colors.green[600] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Status Icon
                        Icon(
                          isDone ? Icons.check_circle : Icons.cancel,
                          color: isDone ? Colors.green : Colors.red,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Summary Card
            Card(
              color: Colors.lightGreen[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: 
                Column(children: [
                  Text(
                    '   Đã đong: ${NumberFormatter.formatNumber(doneTotalML)}ml',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  Text(
                    'Đã đong: ${NumberFormatter.formatNumber(doneTotalGram)}g',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
                )
              ),
            ),

            // Progress indicator
            if (!_allIngredientsDone) ...[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Tiến độ: ${ingredientDone.values.where((done) => done).length}/${widget.recipe.ingredients.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ingredientDone.values.where((done) => done).length / widget.recipe.ingredients.length,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('← Quay lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _allIngredientsDone ? _showCompletionDialog : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('✅ Đã pha xong'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allIngredientsDone ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              color: Colors.blueGrey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng chi phí: ${_formatCurrency(_calculateTotalCost())}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),    
                  ],
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
