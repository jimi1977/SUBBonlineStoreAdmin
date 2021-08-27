import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:subbonline_storeadmin/repository/user_level_repository.dart';
import 'package:subbonline_storeadmin/utility/utility_functions.dart';
import 'package:subbonline_storeadmin/viewmodels/user_login_view_model.dart';

class UsersListPage extends StatefulWidget {
  static const id = "user_list_page";

  const UsersListPage({Key key}) : super(key: key);

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  Future<List<StoreUsers>> futureStoreUser;
  String displayDate;
  String userStatus;

  @override
  void initState() {
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    futureStoreUser = userLoginViewModel.getStoreUsersList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Users List"),
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios)),
      ),
      body: Container(
        child: FutureBuilder<List<StoreUsers>>(
            future: futureStoreUser,
            builder: (context, AsyncSnapshot<List<StoreUsers>> snapshot) {
              if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

                           print("User List Future Builder rebuild");

              return UserListTableWidget(
                users: snapshot.data,

                  );
            }),
      ),
    );
  }
}

class UserListTableWidget extends StatefulWidget {
  final List<StoreUsers> users;


  UserListTableWidget({this.users});

  @override
  _UserListTableWidgetState createState() => _UserListTableWidgetState(users);
}

class _UserListTableWidgetState extends State<UserListTableWidget> {


  final List<StoreUsers> users;


  List<bool> selected;
  _UserListTableWidgetState(this.users):
        selected = List<bool>.generate(users.length, (int index) => false);


  String displayDate;
  String userStatus;

  String getRoleName(int roleId) {
    var roles = userLevels.firstWhere((element) =>  element['level'] == roleId , orElse: () => null);
    return roles['name'];
  }

  int getSelectedIndex() {
    return selected.indexOf(true);
  }

  @override
  Widget build(BuildContext context) {
    var listOfUsers = List.generate(users.length, (index) {
      var _dateCreated = convertTimeStampToDatetime(Timestamp.fromDate(users[index].dateCreated));
      displayDate = DateFormat('EEE, MMM d, ' 'yyyy').format(_dateCreated);

      if (users[index].status == "A") {
        userStatus = "Active";
      } else {
        userStatus = "InActive";
      }

      return DataRow(
        selected: selected[index],
        onSelectChanged: (bool value) {
          setState(() {
            selected = List.filled(users.length, false);
            selected[index] = value;
            Navigator.pop(context, users[index]);
          });
        },
        color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              // All rows will have the same selected color.
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.5);
              }
              // Even rows will have a grey color.
              if (index.isOdd) {
                return Colors.grey.withOpacity(0.3);
              }
              return null; // Use default value for other states and odd rows.
            }),
        cells: <DataCell>[

          DataCell(Text(users[index].userId)),
          DataCell(Text(users[index].name)),
          DataCell(
            Text("${getRoleName(users[index].roleCode)}"),
          ),
          DataCell(Text(userStatus)),
          DataCell(Text("$displayDate")),
        ],
      );
    });
    return Container(
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Scrollbar(
          thickness: 6,
          radius: Radius.circular(25),
          showTrackOnHover: true,
          hoverThickness: 6,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: ScrollPhysics(parent: RangeMaintainingScrollPhysics()),
            child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.orangeAccent),
                headingRowHeight: 30,
                dataRowHeight: 40,
                columnSpacing: 25,
                showBottomBorder: true,
                showCheckboxColumn: false,
                columns: const <DataColumn>[
                  DataColumn(
                      tooltip: "User Id",
                      label: Text(
                        "User Id",
                        style: k14BoldBlack,
                      )),
                  DataColumn(
                      tooltip: "Name",
                      label: Text(
                        "Name",
                        style: k14BoldBlack,
                      )),
                  DataColumn(
                      tooltip: "Role",
                      label: Text(
                        "Role",
                        style: k14BoldBlack,
                      )),
                  DataColumn(
                      tooltip: "Status",
                      label: Text(
                        "Status",
                        style: k14BoldBlack,
                      )),
                  DataColumn(
                      tooltip: "Date Created",
                      label: Text(
                        "Date Created",
                        style: k14BoldBlack,
                      )),
                ],
                rows: listOfUsers),
          ),
        ),
      ),
    );
  }
}
