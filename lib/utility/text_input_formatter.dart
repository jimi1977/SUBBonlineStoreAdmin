import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class FirstCharUpperTextFormatter extends TextInputFormatter {
  String formatText(String text) {
    if (text.isEmpty){
      return '';
    }
    return text[0].toUpperCase() + (text.length > 0 ? text.substring(1) : '');
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: formatText(newValue.text),
      selection: newValue.selection,
    );
  }
}


class CurrencyInputFormatter extends TextInputFormatter {

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    if(newValue.selection.baseOffset == 0){
      print(true);
      return newValue;
    }

    var _newValue = newValue.text;
    _newValue = _newValue.replaceAll(",", "");

    double value = double.parse(_newValue);
    print("UnFormatted Value $value");
    final formatter = NumberFormat.currency(locale: "en_PK", name: "Rs ", decimalDigits: 2,customPattern: '###,###.##', );

    String newText = formatter.format(value);
    if (newText.startsWith(",")){
      newText = newText.replaceFirst(",", "");
    }
    print("Formatted Value $newText");
    return newValue.copyWith(
        text: newText == null ? "0.00" : newText,
        selection: newValue.selection
    );
  }
}
