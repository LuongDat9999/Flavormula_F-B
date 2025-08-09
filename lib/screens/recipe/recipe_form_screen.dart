import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../constants/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/number_formatter.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe; // For editing existing recipe

  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<IngredientFormData> _ingredients = [];
  bool _isLoading = false;

  final List<String> _availableUnits = ['ml', 'g'];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _ingredients.addAll(
        widget.recipe!.ingredients.map((ingredient) {
          final formData = IngredientFormData();
          formData.nameController.text = ingredient.name;
          formData.ratioController.numericValue = ingredient.ratio;
          formData.selectedUnit = _availableUnits.contains(ingredient.unit) 
              ? ingredient.unit 
              : 'ml'; // Default to ml if unit not in available units
          formData.priceController.numericValue = ingredient.price;
          formData.baseQuantityController.numericValue = ingredient.baseQuantity;
          return formData;
        }),
      );
    } else {
      // Add one empty ingredient by default
      _addIngredient();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var ingredient in _ingredients) {
      ingredient.nameController.dispose();
      ingredient.ratioController.dispose();
      ingredient.priceController.dispose();
      ingredient.baseQuantityController.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientFormData());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      final ingredient = _ingredients[index];
      ingredient.nameController.dispose();
      ingredient.ratioController.dispose();
      ingredient.priceController.dispose();
      ingredient.baseQuantityController.dispose();
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    
    if (authProvider.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu công thức')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert form data to ingredients
      final ingredients = _ingredients.map((formData) {
        return Ingredient(
          name: formData.nameController.text.trim(),
          ratio: formData.ratioController.numericValue,
          unit: formData.selectedUnit,
          price: formData.priceController.numericValue,
          baseQuantity: formData.baseQuantityController.numericValue,
        );
      }).toList();

      final recipe = Recipe.create(
        title: _titleController.text.trim(),
        ingredients: ingredients,
      );

      bool success;
      if (widget.recipe != null) {
        // Update existing recipe
        success = await recipeProvider.updateRecipe(
          authProvider.currentUserId!,
          widget.recipe!.id!,
          recipe,
        );
      } else {
        // Create new recipe
        success = await recipeProvider.createRecipe(
          authProvider.currentUserId!,
          recipe,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipe != null 
                ? 'Cập nhật công thức thành công!' 
                : 'Tạo công thức thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Return true to indicate success for editing
        Navigator.pop(context, true);
      } else {
        throw Exception('Lỗi lưu công thức');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.recipe != null ? 'Chỉnh sửa công thức' : 'Tạo công thức mới',
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Recipe Title Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tên công thức',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Tên món ăn',
                                hintText: 'Nhập tên món ăn...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.local_drink),
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập tên món ăn';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 0),
                    
                    // Ingredients Section Header
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tổng số nguyên liệu ${_ingredients.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height:0),
                    
                    // Ingredients List
                    ..._ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ingredient = entry.value;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with ingredient number and delete button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
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
                                      const SizedBox(width: 12),
                                      Text(
                                        'Nguyên liệu ${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_ingredients.length > 1)
                                    IconButton(
                                      onPressed: () => _removeIngredient(index),
                                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                                      tooltip: 'Xóa nguyên liệu',
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Ingredient Name
                              TextFormField(
                                controller: ingredient.nameController,
                                decoration: InputDecoration(
                                  labelText: 'Tên nguyên liệu',
                                  hintText: 'Ví dụ: Trà xanh, Đào hộp, Đường...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.label),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập tên nguyên liệu';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Ratio and Unit
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: ingredient.ratioController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [NumberFormatter.numberInputFormatter],
                                      onEditingComplete: () {
                                        ingredient.ratioController.formatOnComplete();
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Số lượng (${ingredient.selectedUnit})',
                                        hintText: '20',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.scale),
                                        filled: true,
                                        fillColor: Colors.blueGrey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập tỉ lệ';
                                        }
                                        if (NumberFormatter.parseNumber(value) <= 0) {
                                          return 'Tỉ lệ phải lớn hơn 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      value: ingredient.selectedUnit,
                                      decoration: InputDecoration(
                                        labelText: 'Đơn vị',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.blueGrey[50],
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 16,
                                        ),
                                      ),
                                      items: _availableUnits.map((String unit) {
                                        return DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(
                                            unit,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          ingredient.selectedUnit = newValue ?? 'ml';
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng chọn đơn vị';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 10),
                              Text(
                                'Giá nhập nguyên liệu:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Price and Base Quantity
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: ingredient.priceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [CurrencyFormatter.currencyInputFormatter],
                                      decoration: InputDecoration(
                                        labelText: 'Giá (VNĐ)',
                                        hintText: '100,000',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.attach_money),
                                        filled: true,
                                        fillColor: Colors.blueGrey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập giá';
                                        }
                                        if (CurrencyFormatter.parseCurrency(value) <= 0) {
                                          return 'Giá phải lớn hơn 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: ingredient.baseQuantityController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [NumberFormatter.numberInputFormatter],
                                      onEditingComplete: () {
                                        ingredient.baseQuantityController.formatOnComplete();
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Số (${ingredient.selectedUnit})/ giá',
                                        hintText: '100',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.inventory),
                                        filled: true,
                                        fillColor: Colors.blueGrey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập số lượng cơ bản';
                                        }
                                        if (NumberFormatter.parseNumber(value) <= 0) {
                                          return 'Số lượng phải lớn hơn 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Info Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.blue.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '💡 Mẹo: Tỉ lệ là số lượng nguyên liệu cần cho 1 ly. Ví dụ: tỉ lệ 20ml nghĩa là cần 20ml cho 1 ly.',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom action buttons: Save (left) and Add Ingredient (right)
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.recipe != null ? Icons.save : Icons.add_circle,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.recipe != null ? 'Cập nhật công thức' : 'Lưu công thức',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          
                          SizedBox(width: 8),
                          Text(
                            'Thêm nguyên liệu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to manage form data for ingredients
class IngredientFormData {
  final TextEditingController nameController = TextEditingController();
  final NumberTextEditingController ratioController = NumberTextEditingController();
  final CurrencyTextEditingController priceController = CurrencyTextEditingController();
  final NumberTextEditingController baseQuantityController = NumberTextEditingController();
  String selectedUnit = 'ml'; // Default unit
}
