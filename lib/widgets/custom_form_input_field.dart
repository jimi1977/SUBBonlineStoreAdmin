import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class CustomInputFormField extends StatefulWidget {
  final String hintText;
  final String helperText;
  final String labelText;
  final String dbValue;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final IconData suffixIcon;
  final String errorText;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextInputFormatter textInputFormatter;
  final bool autoFocus;
  final bool enable;
  final String initialValue;
  final int maxLength;
  final FocusNode focusNode;
  final Function validateFunction;
  final Function onSaveFunction;
  final Function onFieldSubmittedFunction;
  final Function onTapFunction;
  final Function suffixIconFunction;
  final Function onChangeFunction;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;
  final int minLines;
  final int maxLines;
  final double width;
  final double height;

  CustomInputFormField(
      {this.hintText,
      this.helperText,
      this.labelText,
      this.dbValue,
      this.prefixIcon,
      this.prefixIconColor,
      this.suffixIcon,
      this.errorText,
      @required this.textEditingController,
      this.textInputType,
      this.obscureText,
      @required this.textInputAction,
      this.textAlign,
      this.textDirection,
      this.textInputFormatter,
      @required this.autoFocus,
      @required this.enable,
      this.initialValue,
      this.maxLength,
      this.focusNode,
      this.validateFunction,
      this.onSaveFunction,
      this.onFieldSubmittedFunction,
      this.onTapFunction,
      this.suffixIconFunction,
      this.onChangeFunction,
      this.padding,
      this.contentPadding,
      this.minLines,
      this.maxLines,
      this.width,
      this.height});

  @override
  _CustomInputFormFieldState createState() => _CustomInputFormFieldState();
}

class _CustomInputFormFieldState extends State<CustomInputFormField> {
  OutlineInputBorder _outlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(3.0),
          bottomLeft: Radius.circular(3.0),
          topLeft: Radius.circular(3.0),
          topRight: Radius.circular(3.0),
        ));
  }

  @override
  void initState() {
    if (widget.dbValue != null) {
      widget.textEditingController.text = widget.dbValue;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding == null ? EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5) : widget.padding,
      child: ConstrainedBox(
        constraints: BoxConstraints.tight(Size(widget.width, widget.height == null ? 65 : widget.height)),
        child: TextFormField(
          enableInteractiveSelection: true,
          textAlign: widget.textAlign == null ? TextAlign.left : widget.textAlign,
          maxLength: widget.maxLength,
          enabled: widget.enable,
          controller: widget.textEditingController,
          keyboardType: widget.textInputType,
          obscureText: widget.obscureText ?? false,
          style: kTextInputStyle,
          textInputAction: widget.textInputAction,
          autofocus: widget.autoFocus,
          focusNode: widget.focusNode != null ? widget.focusNode : null,
          minLines: widget.minLines == null ? 1 : widget.minLines,
          maxLines: widget.maxLines == null ? 1 : widget.maxLines,
          inputFormatters: widget.textInputFormatter == null ? null : [widget.textInputFormatter],
          decoration: InputDecoration(
            isDense: true,
            counter: SizedBox.shrink(),
            alignLabelWithHint: true,
            //labelText: hintText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            labelText: widget.labelText != null ? widget.labelText : null,
            errorText: widget.errorText,

            //hintStyle: kLineStyle,
            errorMaxLines: 2,
            contentPadding: widget.contentPadding != null ? widget.contentPadding : EdgeInsets.symmetric(horizontal: 1, vertical: 8) ,
            border: _outlineInputBorder(Colors.grey),
            //UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, style: BorderStyle.solid)),
            enabledBorder: _outlineInputBorder(Colors.orangeAccent),
            //UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent, style: BorderStyle.solid)),
            focusedBorder: _outlineInputBorder(Colors.blue),
            //UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, style: BorderStyle.solid)),
            errorBorder: _outlineInputBorder(Colors.red),
            //UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, style: BorderStyle.solid)),
            disabledBorder: _outlineInputBorder(Colors.grey),
            //UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, style: BorderStyle.solid)),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: 0.0, bottom: 4, end: 0.0),
                    child: Icon(
                      widget.prefixIcon,
                      size: 18,
                      color: widget.prefixIconColor == null ? Colors.black : widget.prefixIconColor,
                    ),
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                    child: InkWell(
                      onTap: widget.suffixIconFunction,
                      child: Icon(
                        widget.suffixIcon,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            if (widget.onChangeFunction != null) {
              widget.onChangeFunction(value);
            }
          },
          validator: widget.validateFunction,
          onSaved: widget.onSaveFunction,
          onEditingComplete: widget.onFieldSubmittedFunction,
          onTap: widget.onTapFunction,
        ),
      ),
    );
  }
}

class CustomDropDownWidget extends StatefulWidget {
  final String hintText;
  final String helperText;
  final String labelText;
  final TextStyle labelStyle;
  final String errorText;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final List<DropdownMenuItem<dynamic>> dropDownValues;
  final dynamic selectedValue;
  final Function validatorFunction;
  final Function setValueFunction;
  final Function onChangeFunction;
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final FocusNode focusNode;
  final bool enable;

  CustomDropDownWidget(
      {Key key,
      this.hintText,
      this.helperText,
      this.errorText,
      this.labelText,
      this.labelStyle,
      this.prefixIcon,
      this.prefixIconColor,
      this.dropDownValues,
      this.selectedValue,
      this.validatorFunction,
      this.setValueFunction,
      this.onChangeFunction,
      this.width,
      this.height,
      this.padding,
      this.contentPadding,
      this.focusNode,
      this.enable});


  @override
  _CustomDropDownWidgetState createState() => _CustomDropDownWidgetState();
}

class _CustomDropDownWidgetState extends State<CustomDropDownWidget> {
  String _validationErrorText;
  dynamic _selectedValue;

  OutlineInputBorder _outlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(3.0),
          bottomLeft: Radius.circular(3.0),
          topLeft: Radius.circular(3.0),
          topRight: Radius.circular(3.0),
        ));
  }

  _validateDropDownValue(dynamic value) {
    _validationErrorText = widget.validatorFunction(_selectedValue);
    return _validationErrorText;
  }

  @override
  void initState() {
    _selectedValue = widget.selectedValue;
    super.initState();
  }


  @override
  void didUpdateWidget(CustomDropDownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _selectedValue = widget.selectedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedValue = _selectedValue == null ? widget.selectedValue : _selectedValue;
    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(widget.width, widget.height == null ? 65 : widget.height)),
      child: Padding(
        padding: widget.padding == null ? EdgeInsets.only(bottom: 1, top: 1, left: 5, right: 5) : widget.padding,
        child: FormField(
          key: widget.key,
          enabled: true,
          onSaved: (value) {
            widget.setValueFunction(_selectedValue);
          },
          validator: (value) {
            return _validateDropDownValue(_selectedValue);
          },
          builder: (FormFieldState state) {
            return InputDecorator(
              expands: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: widget.contentPadding == null
                    ? EdgeInsets.symmetric(horizontal: 1, vertical: 14)
                    : widget.contentPadding,
                filled: false,
                enabled: widget.enable,
                hintText: widget.hintText,
                errorText: _validationErrorText,
                labelText: widget.labelText != null ? widget.labelText : null,
                labelStyle: widget.labelStyle != null ? widget.labelStyle : null,
                helperText: widget.helperText,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        size: 18,
                        color: widget.prefixIconColor == null ? Colors.black : widget.prefixIconColor,
                      )
                    : null,
                focusedErrorBorder: _outlineInputBorder(Colors.red),
                enabledBorder: _outlineInputBorder(Colors.orangeAccent),
                focusedBorder: _outlineInputBorder(Colors.blue),
                errorBorder: _outlineInputBorder(Colors.red),
                disabledBorder: _outlineInputBorder(Colors.grey),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 8),
                height: 30,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    focusNode: widget.focusNode,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    elevation: 1,
                    style: kTextInputStyle,
                    items: widget.dropDownValues,
                    value: _selectedValue,
                    onTap: () {},
                    onChanged: !widget.enable
                        ? null
                        : (value) {
                            widget.onChangeFunction(value);
                            _selectedValue = value;
                            setState(() {});
                          },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
