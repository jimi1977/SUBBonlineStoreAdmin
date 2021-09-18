import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as Path;
import 'package:subbonline_storeadmin/services/image_storage_servcie.dart';

abstract class ImageUploadState {
  const ImageUploadState();
}

class ImageUploadInitial extends ImageUploadState {
  const ImageUploadInitial();
}

class ImageUploading extends ImageUploadState {
  final ImageUpload imageUploading;

  ImageUploading({this.imageUploading});
}

class ImageUploaded extends ImageUploadState {
  final ImageUpload imageUpload;

  ImageUploaded({this.imageUpload});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUploaded && runtimeType == other.runtimeType && imageUpload == other.imageUpload;

  @override
  int get hashCode => imageUpload.hashCode;
}

class ImageUploadError extends ImageUploadState {
  final String errorMessage;

  ImageUploadError(this.errorMessage);
}

class ImageUpload {
  final String imageUrl;
  final File imageFile;

  ImageUpload({this.imageUrl, this.imageFile});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUpload &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          imageFile == other.imageFile;

  @override
  int get hashCode => imageUrl.hashCode ^ imageFile.hashCode;
}

class ImageUploadViewModel extends StateNotifier<ImageUploadState> {
  ImageUploadViewModel(this.imageStorageService) : super(ImageUploadInitial());

  final ImageStorageService imageStorageService;

  ImageUploaded previousState;

  ImageUploaded newState;

  initialise() {
    previousState = null;
    newState = null;
    state = ImageUploadInitial();
  }

  setImageUrl(String imageUrl) {
    final ImageUpload _imageUpload = ImageUpload(imageUrl: imageUrl);
    state = ImageUploaded(imageUpload: _imageUpload);
    previousState = ImageUploaded(imageUpload: _imageUpload);
  }
  bool isImageChanged() {
    if (newState != null && newState != previousState) {
      return true;
    }
    return false;
  }

  setImageFile(File imageFile) {
    state = ImageUploaded(imageUpload: ImageUpload(imageFile: imageFile));
    newState = state;
  }

  Future<String> uploadImage(String fileName, String bucket) async {
    String imageDownloadUrl;
    if (state is ImageUploaded) {
      if (previousState != null && previousState == state) {
        return previousState.imageUpload.imageUrl;
      }
      else if (previousState != null && previousState.imageUpload.imageUrl != null) {
        bool deleteStatus = await removeImageFromBucket(previousState.imageUpload.imageUrl);
        if (!deleteStatus) {
          throw imageStorageService.errorMessage;
        }

      }
      try {
        imageDownloadUrl = await saveImage(newState.imageUpload.imageFile, fileName, bucket);
      } on Exception catch (e) {
        state = ImageUploadError(e.toString());
      }
    } else {
      state = ImageUploadError("Image File is not available to upload");
    }
    return imageDownloadUrl;
  }

  Future<String> saveImage(File imageFile, String fileName, String bucket) async {
    String _filePath = bucket + '/' + fileName;
    String _downLoadURL;
    state = ImageUploading(imageUploading: ImageUpload(imageFile: imageFile));
    try {
      _downLoadURL = await imageStorageService.uploadImage(imageFile, _filePath);
      state = ImageUploaded(imageUpload: ImageUpload(imageFile: imageFile, imageUrl: _downLoadURL));
    } on Exception catch (e) {
      state = ImageUploadError(e.toString());
    }
    return _downLoadURL;
  }

  Future<bool> removeImageFromBucket(String imageUrl) async {
    assert(imageUrl != null);
    String imageName = getImageNameFromURL(imageUrl);
    try {
      return await imageStorageService.deleteImage(imageName);
    } on Exception catch (e) {
      state = ImageUploadError(e.toString());
    }
  }

  String getImageNameFromURL(String imageUrl) {
    var fileUrl = Uri.decodeFull(Path.basename(imageUrl)).replaceAll(new RegExp(r'(\?alt).*'), '');
    return fileUrl;
  }
}
