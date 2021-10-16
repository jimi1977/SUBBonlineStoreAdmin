import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/store.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/shared_preferences_service.dart';
import 'package:subbonline_storeadmin/viewmodels/store_branch_selection_view_model.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';


final storeBranchSelectionProvider = ChangeNotifierProvider.autoDispose<StoreBranchSelectionViewModel>(

    (ref) => StoreBranchSelectionViewModel(storeService: ref.watch(storeServiceProvider),
        sharedPreferencesService: ref.watch(sharedPreferencesServiceProvider)
    )
);

class StoreBranchSelectionWidget extends ConsumerWidget {
  final storeCache = AsyncCache<List<Store>>(const Duration(minutes: 30));
  final branchCache = AsyncCache<List<StoreBranch>>(const Duration(minutes: 0));

  var _selectedStore;
  String _storeId;

  double width;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final storeBranchSelectionModel = watch(storeBranchSelectionProvider);
    width = MediaQuery.of(context).size.width;

    Future<List<Store>> _getStoresListFuture() => storeCache.fetch(() {
          return storeBranchSelectionModel.getAllActiveStores();
        });

    Future<List<StoreBranch>> _getStoreBranchesListFuture(String storeId) => branchCache.fetch(() {
          return storeBranchSelectionModel.getActiveStoreBranches(storeId);
        });

    void storeIdSave(dynamic value) {
      if (value.isNotEmpty) {
        storeBranchSelectionModel.setStoreId(value as String);
        storeBranchSelectionModel.setBranchId(null);
      } else
        storeBranchSelectionModel.setStoreId(null);
    }
    void branchIdSave(dynamic value) {
      if (value.isNotEmpty) {
        storeBranchSelectionModel.setBranchId(value as String);
      } else
        storeBranchSelectionModel.setBranchId(null);
    }

    Widget buildStoresList() {
      return FutureBuilder(
        future: _getStoresListFuture(),
        builder: (context, AsyncSnapshot<List<Store>> snapshot) {
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return Container();
          }
          List<Store> _stores = snapshot.data;
          List<DropdownMenuItem<String>> items = [];
          _stores.forEach((element) {
            items.add(DropdownMenuItem(
              child: Text("${element.store}"),
              value: element.storeCode,
            ));
          });
          return Container(
            child: CustomDropDownWidget(
              enable: true,
              hintText: "Stores",
              //helperText: "Select a store.",
              labelText: "Store",
              selectedValue: storeBranchSelectionModel.storeId,
              width: width * 0.40,
              height: 45,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              dropDownValues: items,
              setValueFunction: storeIdSave,
              validatorFunction: (value) {},
              onChangeFunction: storeIdSave,
            ),
          );
        },
      );
    }

    Widget buildBranchesList() {
      return FutureBuilder(
        future: _getStoreBranchesListFuture(storeBranchSelectionModel.storeId),
        builder: (context, AsyncSnapshot<List<StoreBranch>> snapshot) {
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return Container();
          }
          List<StoreBranch> _branches;
          if (!snapshot.hasData) {
             _branches = [];
          }
          else {
            _branches = snapshot.data;
          }

          List<DropdownMenuItem<String>> branches = [];
          _branches.forEach((element) {
            branches.add(DropdownMenuItem(
              child: Text("${element.name}"),
              value: element.branchId,
            ));
          });
          return Container(
            child: CustomDropDownWidget(
              enable: true,
              hintText: "Branch",
              labelText: "Branch",
              selectedValue: storeBranchSelectionModel.branchId,
              width: width * 0.45,
              height: 45,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              dropDownValues: branches,
              setValueFunction: branchIdSave,
              validatorFunction: (value) {},
              onChangeFunction:branchIdSave
            ),
          );
        },
      );
    }


    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStoresList(),
          buildBranchesList()
        ],
      ),
    );
  }
}
