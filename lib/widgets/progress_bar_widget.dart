


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/viewmodels/progress_bar_view_model.dart';

class ProgressBarWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final progressBarViewModel = watch(progressViewModelProvider);
    return Visibility(
      visible: progressBarViewModel,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: LinearProgressIndicator(
          backgroundColor: Colors.orange.shade400,
          minHeight: 4,

          valueColor: AlwaysStoppedAnimation<Color> (
            Colors.red,
          ),

        ),
      ),
    );
  }
}
