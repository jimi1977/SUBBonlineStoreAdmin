



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/viewmodels/progress_bar_view_model.dart';

class CustomLoadingBar {
  static final  container = ProviderContainer();

  static show() {

    final progressBarViewModel = container.read(progressViewModelProvider.notifier);
    Future.delayed(Duration(milliseconds: 10),).then((value) => progressBarViewModel.startProgress());
  }

  static dismiss() {

    final progressBarViewModel = container.read(progressViewModelProvider.notifier);
    Future.delayed(Duration(milliseconds: 1000),).then((value) => progressBarViewModel.stopProgress());
  }



}