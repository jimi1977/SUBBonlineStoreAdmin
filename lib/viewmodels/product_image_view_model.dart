import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:subbonline_storeadmin/enums/viewstate.dart';




class ProductImage {
  File image;
  String imageName;
  String downloadURL;
  bool isComplete;

  ProductImage({this.image, this.downloadURL});

}

final productImageModel = ChangeNotifierProvider.family((ref, id) => ProductImagesModel());

class ProductImagesModel  with ChangeNotifier {
  List<ProductImage> productImages = [];

  final picker = ImagePicker();


  ImageSource _imageSource;

  ImageSource get imageSource => _imageSource;


  ViewState _state = ViewState.Idle;


  ViewState get state => _state;

  set imageSource(ImageSource value) {
    _imageSource = value;
  }

  initModel(){
    productImages = [];
  }

  Future<XFile> getImage({@required ImageSource source}) async {
    return await picker.pickImage(source: source);
  }

  Future<File> cropImage(File imageFile) async {
    File cropped = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
        ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
        ]
        : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.orange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (cropped != null) {
      return cropped;
    }
  }

  List<ProductImage> getProductImages() {
    return productImages;
  }

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

}
