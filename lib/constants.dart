

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


const kAppTitle = "SUBBonline Store";

const kStoreKey = "SUBO";

const kFontFamily = 'Roboto';

const kGlobalCurrency = "Rs.";

const kPaymentTypeCash = "Cash";

const kMainPalette =  Color(0xFFFD7465);

const kDefaultDeliveryRange = 5.0;

const kTextInputStyle = TextStyle(fontFamily: kFontFamily, fontSize: 14.0, color: Colors.black);
const kTextInputStyleGrey = TextStyle(fontFamily: kFontFamily, fontSize: 14.0, color: Colors.grey);

const kHeaderTextStyle = TextStyle(fontFamily: kFontFamily, fontSize: 16.0);

const kNameTextStyle = TextStyle(fontFamily: kFontFamily, fontSize: 14.0, fontWeight: FontWeight.w500);
const kNameTextStyle15 = TextStyle(fontFamily: kFontFamily, fontSize: 15.0, fontWeight: FontWeight.w500);

const kNumberTextStyle = TextStyle(fontFamily: kFontFamily, fontSize: 13.0,);
const kErrorTextStyle = TextStyle(fontFamily: kFontFamily, fontSize: 12.0, color: Colors.red);



const kOrderTextStyle = TextStyle(fontFamily: kFontFamily, fontSize: 14.0,color: Colors.green,fontWeight: FontWeight.bold);

const k14BoldBlue = TextStyle(fontFamily: kFontFamily, fontSize: 14.0,color: Colors.blue,fontWeight: FontWeight.bold);
const k14BoldGrey = TextStyle(fontFamily: kFontFamily, fontSize: 14.0,color: Colors.grey,fontWeight: FontWeight.bold);

const k14BoldRed = TextStyle(fontFamily: kFontFamily, fontSize: 14.0,color: Colors.red,fontWeight: FontWeight.bold);
const k14BoldBlack = TextStyle(fontFamily: kFontFamily, fontSize: 14.0,color: Colors.black,fontWeight: FontWeight.bold);
const k16BoldBlack = TextStyle(fontFamily: kFontFamily, fontSize: 16.0,color: Colors.black,fontWeight: FontWeight.bold);
const k16Black = TextStyle(fontFamily: kFontFamily, fontSize: 16.0,color: Colors.black,);

const k16Colored = TextStyle(
    color: Color(0xFF563734), fontFamily: kFontFamily, fontSize: 16.0);

const kOrderStatusTextStyleG = TextStyle(fontFamily: kFontFamily, fontSize: 16.0,color: Colors.green,fontWeight: FontWeight.bold);

const kOrderStatusTextStyleR = TextStyle(fontFamily: kFontFamily, fontSize: 16.0,color: Colors.red,fontWeight: FontWeight.bold);



const kLineStyle =
TextStyle(fontFamily: kFontFamily, fontSize: 14.0, color: Colors.grey);


OutlineInputBorder outlineInputBorder(Color borderColor) {
  return OutlineInputBorder(
      borderSide: BorderSide(
        color: borderColor,
        width: 1,
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(3.0),
        bottomLeft: Radius.circular(3.0),
        topLeft: Radius.circular(3.0),
        topRight: Radius.circular(3.0),
      ));
}