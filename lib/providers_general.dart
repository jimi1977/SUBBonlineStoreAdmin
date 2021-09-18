import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/brand_service.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/services/customer_service.dart';
import 'package:subbonline_storeadmin/services/geocoding_service.dart';
import 'package:subbonline_storeadmin/services/image_storage_servcie.dart';
import 'package:subbonline_storeadmin/services/order_service.dart';
import 'package:subbonline_storeadmin/services/store_service.dart';
import 'package:subbonline_storeadmin/services/store_users_service.dart';
import 'package:subbonline_storeadmin/viewmodels/branch_schedule_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/image_upload_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/past_orders_view_model.dart';

final firebaseAuthProvider =
Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider.autoDispose<User>(
        (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final storeServiceProvider = Provider<StoreService>((ref) => StoreService());

final storeUsersServiceProvider = Provider<StoreUserService>((ref) => StoreUserService());

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final customerOrderServiceProvider = Provider<CustomerService>((ref) => CustomerService());

final brandServiceProvider = Provider<BrandService>((ref) => BrandService());

final orderWidgetSelectProvider = StateProvider((ref) => 0);

final pastOrdersProvider = ChangeNotifierProvider<PastOrdersViewModel>((ref) => PastOrdersViewModel());

final branchScheduleViewProvider = ChangeNotifierProvider<BranchScheduleViewModel>((ref) => BranchScheduleViewModel());

final imageServiceProvider = Provider<ImageStorageService>((ref) => ImageStorageService());

final geoCodingServiceProvider = Provider<GeoCodingService>((ref) => GeoCodingService());

final imageUploadProvider = StateNotifierProvider<ImageUploadViewModel, ImageUploadState>((ref) =>
    ImageUploadViewModel(ref.watch(imageServiceProvider))
);

