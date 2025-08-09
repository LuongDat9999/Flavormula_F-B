import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class CurrencyFormatter {
  // Định dạng số thành chuỗi có dấu phẩy ngăn cách hàng nghìn
  static String formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  // Chuyển đổi chuỗi có dấu phẩy thành số
  static double parseCurrency(String value) {
    if (value.isEmpty) return 0;
    // Loại bỏ tất cả dấu phẩy và chuyển thành số
    final cleanValue = value.replaceAll(',', '');
    return double.tryParse(cleanValue) ?? 0;
  }

  // TextInputFormatter để tự động định dạng khi nhập
  static TextInputFormatter get currencyInputFormatter {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;
      
      // Nếu text rỗng, trả về text rỗng
      if (text.isEmpty) {
        return newValue.copyWith(text: '');
      }
      
      // Loại bỏ tất cả ký tự không phải số
      final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
      
      // Nếu không có số nào, trả về text rỗng
      if (digitsOnly.isEmpty) {
        return newValue.copyWith(text: '');
      }
      
      // Chuyển thành số và định dạng lại
      final number = int.parse(digitsOnly);
      final formatted = formatCurrency(number.toDouble());
      
      return newValue.copyWith(text: formatted);
    });
  }
}

// Custom TextEditingController để tự động định dạng số tiền
class CurrencyTextEditingController extends TextEditingController {
  CurrencyTextEditingController({String? text}) : super(text: text) {
    if (text != null && text.isNotEmpty) {
      this.text = CurrencyFormatter.formatCurrency(
        CurrencyFormatter.parseCurrency(text)
      );
    }
  }

  @override
  set text(String value) {
    if (value.isEmpty) {
      super.text = '';
      return;
    }
    
    // Nếu giá trị hiện tại khác với giá trị mới (đã được định dạng)
    final currentFormatted = CurrencyFormatter.formatCurrency(
      CurrencyFormatter.parseCurrency(value)
    );
    
    if (currentFormatted != value) {
      super.text = currentFormatted;
    } else {
      super.text = value;
    }
  }

  // Lấy giá trị số từ controller
  double get numericValue => CurrencyFormatter.parseCurrency(text);
  
  // Set giá trị số cho controller
  set numericValue(double amount) {
    text = CurrencyFormatter.formatCurrency(amount);
  }
}
