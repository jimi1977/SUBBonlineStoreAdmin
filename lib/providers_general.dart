import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/brand_service.dart';
import 'package:services/category_service.dart';
import 'package:services/shelf.dart';
import 'package:services/store_service.dart';
import 'package:subbonline_storeadmin/services/customer_service.dart';
import 'package:subbonline_storeadmin/services/geocoding_service.dart';
import 'package:subbonline_storeadmin/services/image_storage_servcie.dart';
import 'package:subbonline_storeadmin/services/main_category_service.dart';
import 'package:subbonline_storeadmin/services/order_service.dart';
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

final mainCategoryServiceProvider = Provider<MainCategoryService>((ref) => MainCategoryService());

final dealsServiceProvider = Provider<DealsService>((ref) => DealsService());

final categoryServiceProvider = Provider<CategoryService>((ref) => CategoryService());

final geoCodingServiceProvider = Provider<GeoCodingService>((ref) => GeoCodingService());

final translatorServiceProvider = Provider<TranslatorService>((ref) => TranslatorService(fromLanguageCode: 'en', toLanguageCode: 'ur'));

final productServiceProvider = Provider<ProductService>((ref) =>
    ProductService(storeService: ref.watch(storeServiceProvider),
        brandService: ref.watch(brandServiceProvider),
        categoryService: ref.watch(categoryServiceProvider))
);

final imageUploadProvider = StateNotifierProvider<ImageUploadViewModel, ImageUploadState>((ref) =>
    ImageUploadViewModel(ref.watch(imageServiceProvider))
);

