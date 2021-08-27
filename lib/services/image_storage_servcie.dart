


import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ImageStorageService {

  final storage = FirebaseStorage.instance;

  String errorMessage;

  Future<String> uploadImage(File file, String filePath) async {
    String _downloadUrl;
    try {
      UploadTask uploadTask = storage.ref().child(filePath).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        _downloadUrl = await snapshot.ref.getDownloadURL();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        errorMessage = 'User does not have permission to upload to this reference.';
      }
      else
        errorMessage = e.toString();
      throw errorMessage;
    }
    return _downloadUrl;
  }
  Future<bool> deleteImage(String imageURL) async {
    bool deleteStatus = false;
    Reference storageReference = storage.ref().child(imageURL);

    await storageReference
        .delete()
        .then((value) => deleteStatus = true)
        .catchError((onError) => errorMessage = onError.toString());
    return deleteStatus;
  }

}