

import 'package:flutter_riverpod/flutter_riverpod.dart';


final progressViewModelProvider = StateNotifierProvider<ProgressBarViewModel, bool>((ref) => ProgressBarViewModel());

class ProgressBarViewModel extends StateNotifier<bool> {
  ProgressBarViewModel() : super(false);

  Future<void> startProgress() async {
    state = true;
  }

  stopProgress() {
    state = false;
  }

  bool get showProgress => state;

}