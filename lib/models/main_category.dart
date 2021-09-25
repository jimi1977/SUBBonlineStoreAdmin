import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:models/category.dart';

class MainCategory {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final String advertise;
  final String advertText;
  final String textColor;
  final int displaySequence;

  MainCategory(
      {this.id,
      this.name,
      this.type,
      this.imageUrl,
      this.advertise,
      this.advertText,
      this.textColor,
      this.displaySequence});

  List<Category> _category = [];

  List<Category> get category => _category;

  set category(List<Category> value) {
    _category = value;
  }

  factory MainCategory.fromMap(Map<String, dynamic> map) {
    return new MainCategory(
      name: map['name'] as String,
      type: map['type'] as String,
      imageUrl: map['imageUrl'] as String,
      advertise: map['advertise'] as String,
      advertText: map['advertText'] as String,
      textColor: map['textColor'] as String,
      displaySequence: map['displaySequence'],
    );
  }

  factory MainCategory.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data();
    return MainCategory(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      imageUrl: data['imageUrl'],
      advertise: data['advertise'],
      advertText: data['advertText'],
      textColor: data['textColor'],
      displaySequence: data['displaySequence'],
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'name': this.name,
      'type': this.type,
      'imageUrl': this.imageUrl,
      'advertise': this.advertise,
      'advertText': this.advertText,
      'textColor': this.textColor,
      'displaySequence': this.displaySequence,
    } as Map<String, dynamic>;
  }
}
