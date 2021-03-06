import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/viewmodels/image_upload_view_model.dart';

class ImageUploadWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool enable;

  ImageUploadWidget({this.width, this.height, this.enable});

  final ImagePicker _picker = ImagePicker();

  displayMessage(BuildContext context, String message) {
    assert(message != null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.lightBlue,
      duration: Duration(milliseconds: 1000),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Consumer(
      builder: (context, watch, _) {
        final state = watch(imageUploadProvider);
        final model = context.read(imageUploadProvider.notifier);
        if (state is ImageUploaded) {
          return Container(
              child: ProviderListener<ImageUploadState>(
                provider: imageUploadProvider,
                  onChange: (context, state) {
                    if (state is ImageUploadError) {
                      displayMessage(context, state.errorMessage);
                    }
                  },
                  child: buildImageUploadWidget(context, state.imageUpload.imageUrl, state.imageUpload.imageFile, enable)));
        }
        return buildImageUploadWidget(context, null, null, enable );
      },
    ));
  }

  pickNewImage(BuildContext context, String imageUrl, File imageFile,) async {
    String _storeLogo;
    final _pickedImage = await _picker.pickImage(source: ImageSource.gallery,);
    if (_pickedImage != null && _pickedImage.path != null) {
      imageFile = File(_pickedImage.path);
      _storeLogo = _pickedImage.path;
      context.read(imageUploadProvider.notifier).setImageFile(imageFile);
    } else {}
  }

  removeImage(BuildContext context, String imageUrl) {
    context.read(imageUploadProvider.notifier).removeImage();
  }

  Widget buildImageUploadWidget(BuildContext context, String imageUrl, File imageFile, bool enable) {
    String _storeLogo;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 450, maxWidth: 550),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
            child: Container(
              width: width ,
              height: height * 0.90,
              decoration: BoxDecoration(
                  border: Border.all(color: enable ? Colors.orange.shade300 : Colors.grey.shade500, width: 1.2),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : imageFile == null
                              ? AssetImage('images/no-image-available.png')
                              : FileImage(imageFile))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              mainAxisAlignment: imageUrl != null ?  MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
              children: [
                if (imageUrl != null)
                OutlinedButton(
                    style: TextButton.styleFrom(
                        primary: enable ? Colors.blue : Colors.grey,
                        side: BorderSide(color: enable ? Colors.blue : Colors.grey),
                        minimumSize: Size(60, 28),
                        padding: EdgeInsets.all(4)),
                    onPressed: enable
                        ? () async {
                      await removeImage(context, imageUrl);
                      // final _pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                      // if (_pickedImage != null && _pickedImage.path != null) {
                      //   imageFile = File(_pickedImage.path);
                      //   _storeLogo = _pickedImage.path;
                      //   context.read(imageUploadProvider.notifier).setImageFile(imageFile);
                      // } else {}
                    }
                        : null,
                    child: Text(
                      "Remove Image",
                      style: TextStyle(color: enable ? Colors.blue : Colors.grey),
                    )),
                OutlinedButton(
                    style: TextButton.styleFrom(
                        primary: enable ? Colors.blue : Colors.grey,
                        side: BorderSide(color: enable ? Colors.blue : Colors.grey),
                        minimumSize: Size(60, 28),
                        padding: EdgeInsets.all(4)),
                    onPressed:() async {
                      await pickNewImage(context,imageUrl,imageFile, );
                    },
                    child: Text(
                      imageUrl == null? "Upload Image" : "Change Image",
                      style: TextStyle(color: enable ? Colors.blue : Colors.grey),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
