import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/viewstate.dart';
import 'package:subbonline_storeadmin/viewmodels/product_image_view_model.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ProductImagesView extends StatelessWidget {
  int _imageCount = 2;

  File _imageFile;
  int _imageSourceIndex = 0;
  List<ImageSource> _imageSources = [ImageSource.gallery, ImageSource.camera];

  List<ProductImage> productImages = [];
  final Function returnValueFunction;
  final int id;

  ProductImagesView(this.id, this.returnValueFunction, this.productImages);

  initialiseValues() {
    _imageCount = 2;
    _imageFile = null;
    _imageSourceIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    ImageSource _imageSource = _imageSources[_imageSourceIndex];
    print("========== Product Image View Builder Method ==========");
    initialiseValues();
    return Consumer(builder: ((context, watch, _) {
      print('Product Image BaseModel.............. $productImages');
      final model = watch(productImageModel(id));
      model.productImages = productImages;
      if (productImages != null && _imageCount <= productImages.length) {
        _imageCount++;
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Product Images",
                  style: kTextInputStyleGrey,
                ),
                ToggleSwitch(
                  minWidth: 100.0,
                  minHeight: 30,
                  cornerRadius: 20.0,
                  activeBgColor: Colors.cyan,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  labels: ['Upload', 'Capture'],
                  icons: [Icons.sd_storage, Icons.camera_alt],
                  initialLabelIndex: _imageSourceIndex,
                  onToggle: (index) {
                    print('switched to: $index');
                    _imageSourceIndex = index;
                    _imageSource = _imageSources[index];
                    model.imageSource = _imageSource;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 10, left: 5, right: 5),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.orangeAccent, width: 1.5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(3),
                    )),
                width: _width * 0.95,
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageCount,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            Container(
                                width: 100,
                                height: 110,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 2),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    image: DecorationImage(
                                        image: productImages == null || productImages.isEmpty || productImages.length <= index
                                            ? AssetImage('images/background/white_image.jpg')
                                            : productImages[index].downloadURL == null
                                                ? FileImage(_displayImage(model, index))
                                                : NetworkImage(productImages[index].downloadURL),
                                        fit: BoxFit.fill)),
                                //height: double.infinity,

                                child: OutlinedButton(
                                    child: Visibility(
                                      visible: productImages == null ||productImages.isEmpty || productImages.length <= index,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onLongPress: () {
                                      print("onLongPress");
                                      if (productImages != null && productImages.length > index) {
                                        model.setState(ViewState.Busy);
                                        productImages.removeAt(index);
                                        returnValueFunction(productImages);
                                        model.productImages = productImages;
                                        model.setState(ViewState.Idle);
                                      }
                                    },
                                    onPressed: () async {
                                      if (productImages == null || productImages.isEmpty || productImages.length <= index) {
                                      } else
                                        return;

                                      final _pickedImage = await model.getImage(source: _imageSource);
                                      model.setState(ViewState.Busy);
                                      if (_pickedImage != null && _pickedImage.path != null) {
                                        _imageFile = File(_pickedImage.path);
                                        _imageFile = await model.cropImage(_imageFile);
                                        if (_imageFile == null) {
                                          model.setState(ViewState.Idle);
                                          return;
                                        }

                                        ProductImage _productImage = ProductImage(
                                          image: _imageFile,
                                        );
                                        productImages.add(_productImage);
                                        model.productImages = productImages;
                                        returnValueFunction(productImages);
                                        if (_imageCount == productImages.length) {
                                          _imageCount++;
                                        }
                                        model.setState(ViewState.Idle);
                                      }
                                    })),
                          ],
                        ));
                  },
                )),
          ),
        ],
      );
    }));
  }

  File _displayImage(ProductImagesModel model, int index) {
    if (productImages.length > index) {
      return productImages[index].image;
    } else
      return null;
  }
}
