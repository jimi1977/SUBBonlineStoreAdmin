import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';
import 'package:services/shelf.dart';
import 'package:subbonline_storeadmin/services/image_storage_servcie.dart';

import '../providers_general.dart';
import '../services/shared_preferences_service.dart';


abstract class StoreState {
  const StoreState();
}

class StoreInitial extends StoreState {
  const StoreInitial();
}

class StoreImageLoaded extends StoreState {
  const StoreImageLoaded();
}

class StoreSave extends StoreState {
  const StoreSave();
}

final storeViewModelProvider = ChangeNotifierProvider((ref) => StoreViewModel(
    ref.watch(storeServiceProvider), ref.watch(sharedPreferencesServiceProvider), ref.watch(imageServiceProvider)));

class StoreViewModel extends ChangeNotifier {
  StoreViewModel(this.storeService, this.sharedPreferencesService, this.imageStorageService);

  final StoreService storeService;
  final SharedPreferencesService sharedPreferencesService;
  final ImageStorageService imageStorageService;

  String _storeId;
  String _name;
  String _aboutStore;
  String _storeLogo;
  String _status;
  DateTime _createdDate;
  File _imageFile;

  String errorMessage;

  String _downLoadURL;

  buildState() {
    notifyListeners();
  }

  initialise() {
    _storeId = null;
    _name = null;
    _aboutStore = null;
    _storeLogo = null;
    _status = null;
    _imageFile = null;
    errorMessage = null;
    _downLoadURL = null;
    _createdDate = null;
    errorMessage = null;
  }

  setStoreId(String storeId) {
    _storeId = storeId;
  }

  setName(String name) {
    _name = name;
  }

  setAboutStore(String aboutStore) {
    _aboutStore = aboutStore;
  }

  setStatus(String status) {
    _status = status;
  }

  setStoreLogo(String storeLogo) {
    _storeLogo = storeLogo;
  }

  setCreatedDate(DateTime createdDate) {
    _createdDate = createdDate;
  }

  setImageFile(File imageFile) {
    _imageFile = imageFile;
  }

  Future<Store> getMyStore() async {
    String storeId = sharedPreferencesService.getStoreId();
    return await storeService.getStore(storeId);
  }

  Future<Store> getStoreById(String storeId) async {
    return await storeService.getStore(storeId);
  }

  String getStoreId() => _storeId;

  String getStoreName() => _name;

  String getAboutStore() => _aboutStore;

  String getStatus() => _status;

  getImageFile() => _imageFile;

  getStoreLogo() => _storeLogo;

  getCreateDate() => _createdDate;

  Future<bool> saveImage(String storeId, File imageFile) async {
    bool imageUploaded = false;
    String _folder = "store/";
    String _filePath = storeId + "-logo";
    _filePath = _folder + _filePath;
    _downLoadURL = await imageStorageService.uploadImage(imageFile, _filePath);
    if (_downLoadURL == null) {
      imageUploaded = false;
      errorMessage =  imageStorageService.errorMessage;
      throw errorMessage;
    }
    return imageUploaded;
  }

  Future<bool> saveStore() async {
    bool isSave= true;
    bool imageUploaded = true;
    if (getImageFile() != null) {
       try {
         imageUploaded = await saveImage(getStoreId(), getImageFile()) == false;
       } on Exception catch (e) {
         errorMessage = e.toString();
         isSave = false;
         imageUploaded = false;
       }
       if (imageUploaded) {
         setStoreLogo(_downLoadURL);
       }
    }
    if (!isSave) return isSave;

    Store _store = Store(
        storeCode: getStoreId(),
        store: getStoreName(),
        aboutStore: getAboutStore(),
        status: getStatus(),
        storeLogo: getStoreLogo(),
        createDate: getCreateDate()
    );

    try {
      await storeService.saveStore(_store);
    } on Exception catch (e) {
      isSave = false;
      errorMessage = e.toString();
    }
    return isSave;
  }
}
