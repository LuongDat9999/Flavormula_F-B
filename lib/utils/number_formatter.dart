import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NumberFormatter {
  // Định dạng số thành chuỗi có dấu phẩy ngăn cách hàng nghìn
  static String formatNumber(double number) {
    // Kiểm tra nếu là số nguyên thì không hiển thị .0
    if (number == number.toInt()) {
      return number.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    } else {
      return number.toStringAsFixed(1).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    }
  }

  // Định dạng số từ chuỗi, giữ nguyên định dạng gốc nếu có thể
  static String formatNumberFromString(String value) {
    if (value.isEmpty) return '';
    
    // Loại bỏ dấu phẩy để parse
    final cleanValue = value.replaceAll(',', '');
    final number = double.tryParse(cleanValue);
    
    if (number == null) return value;
    
    // Nếu giá trị gốc không có dấu chấm và là số nguyên, giữ nguyên
    if (!value.contains('.') && number == number.toInt()) {
      return number.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    } else {
      // Nếu có dấu chấm hoặc là số thập phân, hiển thị với 1 chữ số thập phân
      return number.toStringAsFixed(1).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    }
  }

  // Chuyển đổi chuỗi có dấu phẩy thành số
  static double parseNumber(String value) {
    if (value.isEmpty) return 0;
    // Loại bỏ tất cả dấu phẩy và chuyển thành số
    final cleanValue = value.replaceAll(',', '');
    return double.tryParse(cleanValue) ?? 0;
  }

  // TextInputFormatter để tự động định dạng khi nhập số
  static TextInputFormatter get numberInputFormatter {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;
      
      // Nếu text rỗng, trả về text rỗng
      if (text.isEmpty) {
        return newValue.copyWith(text: '');
      }
      
      // Loại bỏ tất cả ký tự không phải số và dấu chấm
      final digitsOnly = text.replaceAll(RegExp(r'[^\d.]'), '');
      
      // Nếu không có số nào, trả về text rỗng
      if (digitsOnly.isEmpty) {
        return newValue.copyWith(text: '');
      }
      
      // Kiểm tra xem có nhiều hơn một dấu chấm không
      final dotCount = digitsOnly.split('.').length - 1;
      if (dotCount > 1) {
        return oldValue;
      }
      
      // Cho phép nhập số nguyên và số thập phân
      return newValue.copyWith(text: digitsOnly);
    });
  }
}

// Custom TextEditingController để tự động định dạng số
class NumberTextEditingController extends TextEditingController {
  NumberTextEditingController({String? text}) : super(text: text) {
    if (text != null && text.isNotEmpty) {
      final number = NumberFormatter.parseNumber(text);
      super.text = NumberFormatter.formatNumber(number);
    }
  }

  @override
  set text(String value) {
    // Không tự động định dạng khi set text, chỉ lưu giá trị gốc
    super.text = value;
  }

  // Lấy giá trị số từ controller
  double get numericValue => NumberFormatter.parseNumber(text);
  
  // Set giá trị số cho controller
  set numericValue(double amount) {
    super.text = NumberFormatter.formatNumber(amount);
  }

  // Phương thức để định dạng khi người dùng hoàn thành nhập (onEditingComplete)
  void formatOnComplete() {
    if (text.isNotEmpty) {
      super.text = NumberFormatter.formatNumberFromString(text);
    }
  }
}
